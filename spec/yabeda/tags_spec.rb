# frozen_string_literal: true

RSpec.describe Yabeda::Tags do
  describe ".build" do
    subject(:result) { described_class.build(tags, group) }

    let(:tags) { { controller: "foo" } }
    let(:group) { nil }

    context "when default tags are not set" do
      it { is_expected.to eq(controller: "foo") }
    end

    context "when default tags are set" do
      before do
        Yabeda.configure do
          default_tag :environment, "test"
        end
        Yabeda.configure!
      end

      it { is_expected.to eq(environment: "test", controller: "foo") }
    end

    context "when default tags and passing tags the same" do
      before do
        Yabeda.configure do
          default_tag :controller, "default"
        end
        Yabeda.configure!
      end

      it { is_expected.to eq(controller: "foo") }
    end

    context "when default tags and temporary tags are set" do
      before do
        Yabeda.configure do
          default_tag :controller, "default"
          default_tag :action, "whatever"
          default_tag :format, "html"
        end
        Yabeda.configure!
      end

      let(:tags) { { controller: "foo", id: "100500" } }

      it "overwrites default tags but not metric tags", :aggregate_failures do
        Yabeda.with_tags(controller: "bar", format: "json", q: "test") do
          expect(result).to eq controller: "foo", action: "whatever", format: "json", id: "100500", q: "test"
        end
      end

      it "don't use temporary tags outside with_tags block" do
        Yabeda.with_tags(controller: "bar", format: "json", q: "test") do
          # What happened in with_tags stays in with_tags
        end
        expect(result).to eq controller: "foo", action: "whatever", format: "html", id: "100500"
      end
    end

    context "when a group is specified" do
      before do
        Yabeda.configure do
          default_tag :action, "default"
          default_tag :controller, "default"
          default_tag :key, "value", group: :g1
          default_tag :action, "overridden", group: :g1
          default_tag :absent, "value", group: :g2
        end
        Yabeda.configure!
      end

      it { is_expected.to eq(action: "default", controller: "foo") }

      context "and is built for the group" do
        let(:group) { Yabeda::Group.new(:g1) }

        it { is_expected.to eq(action: "overridden", controller: "foo", key: "value") }
      end
    end
  end
end
