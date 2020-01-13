# frozen_string_literal: true

RSpec.describe Yabeda::Gauge do
  subject(:set_gauge) { gauge.set(tags, metric_value) }

  let(:tags) { { foo: 'bar' } }
  let(:metric_value) { 10 }
  let(:gauge) { ::Yabeda.test_gauge }

  before(:each) do
    ::Yabeda.configure do
      gauge :test_gauge
    end
  end

  it { expect(set_gauge).to eq(metric_value) }

  it 'execute perform_gauge_set! method of adapter' do
    adapter = instance_double('Yabeda::BaseAdapter', perform_gauge_set!: true, register!: true)
    ::Yabeda.register_adapter(:test_adapter, adapter)

    set_gauge

    expect(adapter).to have_received(:perform_gauge_set!).with(gauge, tags, metric_value)
  end

  it 'execute build method of Yabeda::Tags' do
    allow(Yabeda::Tags).to receive(:build).and_return(tags)

    set_gauge

    expect(Yabeda::Tags).to have_received(:build).with(tags)
  end
end
