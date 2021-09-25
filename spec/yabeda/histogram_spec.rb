# frozen_string_literal: true

RSpec.describe Yabeda::Histogram do
  subject(:measure_histogram) { histogram.measure(tags, metric_value) }

  let(:tags) { { foo: "bar" } }
  let(:metric_value) { 10 }
  let(:block) { proc { 1 + 1 } }
  let(:histogram) { ::Yabeda.test_histogram }
  let(:built_tags) { { built_foo: "built_bar" } }
  let(:adapter) { instance_double("Yabeda::BaseAdapter", perform_histogram_measure!: true, register!: true) }

  before do
    ::Yabeda.configure do
      histogram :test_histogram, buckets: [1, 10, 100]
    end
    Yabeda.configure! unless Yabeda.already_configured?
    allow(Yabeda::Tags).to receive(:build).with(tags, anything).and_return(built_tags)
    ::Yabeda.register_adapter(:test_adapter, adapter)
  end

  context "with value given" do
    it { is_expected.to eq(metric_value) }

    it "execute perform_histogram_measure! method of adapter" do
      measure_histogram
      expect(adapter).to have_received(:perform_histogram_measure!).with(histogram, built_tags, metric_value)
    end
  end

  context "with block given" do
    subject(:measure_histogram) { histogram.measure(tags, &block) }

    let(:block) { proc { sleep(0.02) } }

    it { is_expected.to be_between(0.01, 0.05) } # Ruby can sleep more or less than requested

    it "execute perform_histogram_measure! method of adapter" do
      measure_histogram
      expect(adapter).to have_received(:perform_histogram_measure!).with(histogram, built_tags, be_between(0.01, 0.05))
    end
  end

  context "with both value and block provided" do
    subject(:measure_histogram) { histogram.measure(tags, metric_value, &block) }

    it "raises an argument error" do
      expect { measure_histogram }.to raise_error(ArgumentError)
    end
  end

  context "with both value and block omitted" do
    subject(:measure_histogram) { histogram.measure(tags) }

    it "raises an argument error" do
      expect { measure_histogram }.to raise_error(ArgumentError)
    end
  end
end
