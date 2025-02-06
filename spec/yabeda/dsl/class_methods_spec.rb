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

  describe ".configure" do
    subject(:configure) { Yabeda.configure(&block) }

    let(:block) { proc { histogram :test_histogram, buckets: [42] } }

    before do
      Yabeda.register_adapter(:another_adapter, Yabeda::TestAdapter.instance)
      Yabeda.configure! unless Yabeda.configured?
    end

    it "register metric" do
      configure

      expect(Yabeda.test_histogram).to be_a(Yabeda::Histogram)
    end

    context "when got metric with adapter option" do
      let(:block) { proc { histogram :invalid_test, buckets: [42], adapter: :another_adapter } }

      it { expect { configure }.not_to raise_error }

      context "when option is invalid" do
        let(:block) { proc { histogram :invalid_test, buckets: [42], adapter: :invalid } }

        it { expect { configure }.to raise_error(Yabeda::ConfigurationError, /invalid adapter option/) }
      end
    end
  end

  describe ".adapter" do
    context "when group is not defined" do
      it "raises an error" do
        error_message = "Yabeda.adapter should be called either inside group declaration " \
          "or should have block provided with a call to include_group. No metric group provided."

        expect do
          Yabeda.configure { adapter :test }
          Yabeda.configure! unless Yabeda.already_configured?
        end.to raise_error(Yabeda::ConfigurationError, error_message)
      end
    end

    context "with a specified group that does not exist" do
      before do
        Yabeda.configure { adapter :test, group: :adapter_group }
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "creates the group" do
        expect(Yabeda.groups[:adapter_group]).to be_a(Yabeda::Group)
      end

      it "defines the default tag" do
        expect(Yabeda.groups[:adapter_group].adapter).to eq(%i[test])
      end
    end
  end
end
