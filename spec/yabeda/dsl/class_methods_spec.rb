# frozen_string_literal: true

RSpec.describe Yabeda::DSL::ClassMethods do
  describe ".group" do
    context "without block" do
      before do
        Yabeda.configure do
          group :group1
          gauge :test_gauge

          group :group2
          histogram :test_histogram, buckets: [1, 10, 100]
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "defines metric method on the root object" do
        expect(Yabeda.group1_test_gauge).to be_a(Yabeda::Gauge)
        expect(Yabeda.group2_test_histogram).to be_a(Yabeda::Histogram)
      end

      it "defines group methods on the root object" do
        expect(Yabeda.group1).to be_a(Yabeda::Group)
        expect(Yabeda.group2).to be_a(Yabeda::Group)
      end

      it "defines methods on the group objects" do
        expect(Yabeda.group1.test_gauge).to be_a(Yabeda::Gauge)
        expect(Yabeda.group2.test_histogram).to be_a(Yabeda::Histogram)
      end
    end

    context "with block" do
      before do
        Yabeda.configure do
          group(:group1) { gauge(:test_gauge) }
          histogram(:test_histogram, buckets: [1, 10, 100])
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "defines metric method on the root object" do
        expect(Yabeda.group1_test_gauge).to be_a(Yabeda::Gauge)
      end

      it "not attaches metric to a previous group" do
        expect(Yabeda.test_histogram).to be_a(Yabeda::Histogram)
      end

      it "defines group methods on the root object" do
        expect(Yabeda.group1).to be_a(Yabeda::Group)
      end

      it "defines methods on the group objects" do
        expect(Yabeda.group1.test_gauge).to be_a(Yabeda::Gauge)
      end
    end
  end

  describe ".counter" do
    subject { Yabeda.test_counter }

    context "when properly configured" do
      before do
        Yabeda.configure { counter(:test_counter) }
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it("defines method on root object") { is_expected.to be_a(Yabeda::Counter) }
    end
  end

  describe ".gauge" do
    subject { Yabeda.test_gauge }

    context "when properly configured" do
      before do
        Yabeda.configure { gauge(:test_gauge) }
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it("defines method on root object") { is_expected.to be_a(Yabeda::Gauge) }
    end
  end

  describe ".histogram" do
    subject { Yabeda.test_histogram }

    context "when properly configured" do
      before do
        Yabeda.configure { histogram(:test_histogram, buckets: [1, 10, 100]) }
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it("defines method on root object") { is_expected.to be_a(Yabeda::Histogram) }
    end
  end

  describe ".summary" do
    subject { Yabeda.test_summary }

    context "when properly configured" do
      before do
        Yabeda.configure { summary(:test_summary) }
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it("defines method on root object") { is_expected.to be_a(Yabeda::Summary) }
    end
  end

  describe ".default_tag" do
    subject { Yabeda.default_tags }

    context "when default tag configured" do
      before do
        Yabeda.configure { default_tag :environment, "test" }
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it { is_expected.to eq(environment: "test") }
    end

    context "with a specified group that does not exist" do
      before do
        Yabeda.configure { default_tag :environment, "test", group: :missing_group }
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "creates the group" do
        expect(Yabeda.groups[:missing_group]).to be_a(Yabeda::Group)
      end

      it "defines the default tag" do
        expect(Yabeda.groups[:missing_group].default_tags).to eq(environment: "test")
      end
    end

    context "when specified group is defined after default_tag" do
      before do
        Yabeda.configure { default_tag :environment, "test", group: :missing_group }
        Yabeda.configure do
          group :missing_group
          default_tag :key, "value"
          gauge :test_gauge, comment: "..."
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "defines all the tags" do
        expect(Yabeda.groups[:missing_group].default_tags).to eq(environment: "test", key: "value")
      end

      it "test_gauge has all the tags defined" do
        expect(Yabeda.missing_group.test_gauge.tags).to eq(%i[environment key])
      end
    end
  end

  describe ".adapter" do
    context "when block don't given" do
      it "return nil" do
        expect(Yabeda.adapter(:test_adapter_name)).to be_nil
      end
    end

    context "when block given" do
      it "return block result" do
        expect(Yabeda.adapter(:test_adapter_name) { 1 + 1 }).to eq 2
      end
    end
  end

  describe ".include_group" do
    let(:adapter_and_include_group) do
      lambda do
        Yabeda.configure do
          group :test_group do
            counter :test_counter
          end

          adapter :test_adapter_name do
            include_group :test_group
          end
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end
    end

    it "set only_for_adapter value for group" do
      expect(Yabeda.groups[:test_group]).to be_nil
      adapter_and_include_group.call
      expect(Yabeda.groups[:test_group].only_for_adapter).to eq :test_adapter_name
    end
  end
end
