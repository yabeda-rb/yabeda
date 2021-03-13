# frozen_string_literal: true

RSpec.describe Yabeda::Histogram do
  subject(:measure_histogram) { histogram.measure(tags, metric_value) }

  let(:tags) { { foo: "bar" } }
  let(:metric_value) { 10 }
  let(:histogram) { ::Yabeda.test_histogram }
  let(:built_tags) { { built_foo: "built_bar" } }
  let(:adapter) { instance_double("Yabeda::BaseAdapter", perform_histogram_measure!: true, register!: true) }

  before do
    ::Yabeda.configure do
      histogram :test_histogram, buckets: [1, 10, 100]
    end
    Yabeda.configure!
    allow(Yabeda::Tags).to receive(:build).with(tags, anything).and_return(built_tags)
    ::Yabeda.register_adapter(:test_adapter, adapter)
  end

  it { is_expected.to eq(metric_value) }

  it "execute perform_histogram_measure! method of adapter" do
    measure_histogram
    expect(adapter).to have_received(:perform_histogram_measure!).with(histogram, built_tags, metric_value)
  end
end
