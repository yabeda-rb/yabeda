# frozen_string_literal: true

RSpec.describe Yabeda::Counter do
  subject(:increment_counter) { counter.increment(tags, by: metric_value) }

  let(:tags) { { foo: 'bar' } }
  let(:metric_value) { 10 }
  let(:counter) { ::Yabeda.test_counter }

  before(:each) do
    ::Yabeda.configure do
      counter :test_counter
    end
  end
 
  it { expect(increment_counter).to eq(metric_value) }

  it 'execute perform_counter_increment! method of adapter' do
    adapter = instance_double('Yabeda::BaseAdapter', perform_counter_increment!: true, register!: true)
    ::Yabeda.register_adapter(:test_adapter, adapter)

    increment_counter

    expect(adapter).to have_received(:perform_counter_increment!).with(counter, tags, metric_value)
  end

  it 'execute build method of Yabeda::Tags' do
    allow(Yabeda::Tags).to receive(:build).and_return(tags)

    increment_counter

    expect(Yabeda::Tags).to have_received(:build).with(tags)
  end
end
