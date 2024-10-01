# frozen_string_literal: true

RSpec.describe Yabeda::Gauge do
  subject(:set_gauge) { gauge.set(tags, metric_value) }

  let(:tags) { { foo: "bar" } }
  let(:metric_value) { 10 }
  let(:gauge) { Yabeda.test_gauge }
  let(:built_tags) { { built_foo: "built_bar" } }
  let(:adapter) { instance_double(Yabeda::BaseAdapter, perform_gauge_set!: true, register!: true) }

  before do
    Yabeda.configure do
      gauge :test_gauge
    end
    Yabeda.configure! unless Yabeda.already_configured?
    allow(Yabeda::Tags).to receive(:build).with(tags, anything).and_return(built_tags)
    Yabeda.register_adapter(:test_adapter, adapter)
  end

  it { expect(set_gauge).to eq(metric_value) }

  it "execute perform_gauge_set! method of adapter" do
    set_gauge
    expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, metric_value)
  end

  describe "#increment" do
    context "when gauge has no initial value" do
      before { gauge.increment(tags) }

      it { expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, 1) }
    end

    context "when gauge has a value already" do
      before do
        set_gauge
        gauge.increment(tags)
      end

      it { expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, metric_value + 1) }
    end

    context "when custom step specified" do
      it "increases by value of custom step" do
        set_gauge
        gauge.increment(tags, by: 42)
        expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, metric_value + 42)
      end
    end
  end

  describe "#decrement" do
    context "when gauge has no initial value" do
      before { gauge.decrement(tags) }

      it { expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, -1) }
    end

    context "when gauge has a value already" do
      before do
        set_gauge
        gauge.decrement(tags)
      end

      it { expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, metric_value - 1) }
    end

    context "when custom step specified" do
      it "decreases by value of custom step" do
        set_gauge
        gauge.decrement(tags, by: 42)
        expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, metric_value - 42)
      end
    end
  end

  context "with adapter option" do
    let(:gauge) { Yabeda.gauge_with_adapter }
    let(:another_adapter) { instance_double(Yabeda::BaseAdapter, perform_gauge_set!: true, register!: true) }

    before do
      Yabeda.register_adapter(:another_adapter, another_adapter)
      Yabeda.configure do
        gauge :gauge_with_adapter, adapter: :test_adapter
      end
      Yabeda.configure! unless Yabeda.already_configured?
    end

    it "execute perform_counter_increment! method of adapter with name :test_adapter" do
      set_gauge

      aggregate_failures do
        expect(adapter).to have_received(:perform_gauge_set!).with(gauge, built_tags, metric_value)
        expect(another_adapter).not_to have_received(:perform_gauge_set!)
      end
    end
  end
end
