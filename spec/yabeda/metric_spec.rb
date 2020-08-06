# frozen_string_literal: true

RSpec.describe Yabeda::Metric do
  let(:metric)  { described_class.new(name, options) }
  let(:name)    { "some_metric" }
  let(:options) { { tags: %i[foo bar] } }

  describe "#get" do
    subject { metric.get(tags) }

    let(:tags) { { foo: "1", bar: "2" } }

    before do
      metric.instance_variable_set(:@values, { tags => 42 })
    end

    it { is_expected.to eq(42) }

    it "returns nil for absent data" do
      expect(metric.get({ whatever: "else" })).to be_nil
    end

    context "when default tags are set" do
      before do
        Yabeda.configure do
          default_tag :bar, "2"
        end
        Yabeda.configure!
      end

      it "returns value with account for default tags values" do
        expect(metric.get({ foo: "1" })).to eq(42)
      end
    end
  end

  describe "#tags" do
    subject { metric.tags }

    let(:options) { {} }

    it { is_expected.to eq [] }

    context "when metric tags are set" do
      let(:options) { { tags: %i[foo bar] } }

      it { is_expected.to eq options[:tags] }
    end

    context "when default tags are set" do
      let(:options) { { tags: %i[foo bar] } }

      before do
        Yabeda.configure do
          default_tag :bar, "test"
          default_tag :baz, "qux"
        end
        Yabeda.configure!
      end

      it { is_expected.to match_array(%i[foo bar baz]) }
    end
  end
end
