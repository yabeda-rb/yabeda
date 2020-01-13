# frozen_string_literal: true

RSpec.describe Yabeda::DSL::MetricBuilder do
  subject(:metric) do
    described_class.new(test_metric_class).build(args, kwargs, group, &block)
  end

  let(:args) { [:test_metric] }
  let(:kwargs) { { required_option: "value" } }
  let(:group) { nil }
  let(:block) { proc {} }
  let(:test_metric_class) do
    Class.new(Yabeda::Metric) do
      option :required_option
    end
  end

  context "when required option is not provided" do
    let(:kwargs) { {} }

    it "raises error" do
      expect { metric }.to raise_error(
        Yabeda::ConfigurationError,
        /option 'required_option' is required/,
      )
    end
  end

  context "when unknown option is provided" do
    let(:kwargs) { { required_option: nil, buckets: [] } }

    it "raises error" do
      expect { metric }.to raise_error(
        Yabeda::ConfigurationError,
        /option 'buckets' is not available/,
      )
    end
  end

  context "when kwargs provided" do
    it "assignes options" do
      expect(metric).to have_attributes(required_option: "value")
    end
  end

  context "when kwargs and block provided" do
    let(:kwargs) { { comment: "comment" } }
    let(:block) { proc { required_option "value" } }

    it "merges options" do
      expect(metric).to have_attributes(required_option: "value", comment: "comment")
    end
  end

  context "when same option defined inside a block and in kwargs" do
    let(:block) { proc { required_option "new_value" } }

    it "overrides param value" do
      expect(metric).to have_attributes(required_option: "new_value")
    end
  end

  context "when group is provided" do
    let(:group) { "group" }

    it "assignes group" do
      expect(metric).to have_attributes(group: group)
    end
  end
end
