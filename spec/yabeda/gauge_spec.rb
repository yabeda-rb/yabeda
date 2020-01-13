# frozen_string_literal: true

RSpec.describe Yabeda::Gauge do
  subject(:set_gauge) { gauge.set(tags, metric_value) }

  let(:tags) { { foo: 'bar' } }
  let(:metric_value) { 10 }
  let(:gauge) { ::Yabeda.test_gauge }
  let(:built_tags) { { built_foo: 'built_bar' } }
  let(:adapter) { instance_double('Yabeda::BaseAdapter', perform_gauge_set!: true, register!: true) }

  before(:each) do
    ::Yabeda.configure do
      gauge :test_gauge
    end
    allow(Yabeda::Tags).to receive(:build).with(tags).and_return(built_tags)
    ::Yabeda.register_adapter(:test_adapter, adapter)
  end

  after do
    ::Yabeda.adapters.clear
    ::Yabeda.metrics.clear
  end

  it { expect(set_gauge).to eq(metric_value) }

  it 'execute perform_gauge_set! method of adapter' do
    set_gauge
    expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, metric_value)
  end
end
