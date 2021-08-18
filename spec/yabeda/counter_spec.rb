# frozen_string_literal: true

RSpec.describe Yabeda::Counter do
  subject(:increment_counter) { counter.increment(tags, by: metric_value) }

  let(:tags) { { foo: "bar" } }
  let(:metric_value) { 10 }
  let(:counter) { ::Yabeda.test_counter }
  let(:built_tags) { { built_foo: "built_bar" } }
  let(:adapter) { instance_double("Yabeda::BaseAdapter", perform_counter_increment!: true, register!: true) }

  before do
    ::Yabeda.configure do
      counter :test_counter
    end
    Yabeda.configure! unless Yabeda.already_configured?
    allow(Yabeda::Tags).to receive(:build).with(tags, anything).and_return(built_tags)
    ::Yabeda.register_adapter(:test_adapter, adapter)
  end

  it { expect(increment_counter).to eq(metric_value) }

  it "execute perform_counter_increment! method of adapter" do
    increment_counter
    expect(adapter).to have_received(:perform_counter_increment!).with(counter, built_tags, metric_value)
  end
end
