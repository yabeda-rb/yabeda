# frozen_string_literal: true

RSpec.describe Yabeda do
  it "has a version number" do
    expect(Yabeda::VERSION).not_to be_nil
  end

  it "exposes the public api" do
    expect(described_class.metrics).to eq({})
    expect(described_class.adapters).to eq({})
    expect(described_class.collectors).to eq([])
    expect(described_class.default_tags).to eq({})
    expect(described_class.configured?).to be(false)
  end

  describe ".configure!" do
    subject(:configure!) { described_class.configure! }

    it { expect { configure! }.to change(described_class, :configured?).to true }

    context "when called multiple times" do
      before { described_class.configure! }

      it { expect { configure! }.to raise_error(Yabeda::AlreadyConfiguredError) }
    end
  end

  describe ".debug!" do
    subject(:debug!) { described_class.debug! }

    before { described_class.config.debug = false }

    after { described_class.reset! }

    it { expect { debug! }.to change(described_class, :debug?).from(false).to(true) }

    it "registers metrics" do
      described_class.debug!
      described_class.configure!

      expect(described_class.yabeda.collect_duration).to be_a Yabeda::Histogram
    end
  end

  describe ".collect!" do
    subject(:collect!) { described_class.collect! }

    let(:adapter) do
      instance_double(Yabeda::BaseAdapter, perform_histogram_measure!: true, register!: true, debug!: true)
    end
    let(:collector) do
      proc do
        sleep(0.01)
        described_class.test.measure({}, 42)
      end
    end

    before do
      collect_block = collector
      described_class.configure do
        histogram :test, buckets: [42]
        collect(&collect_block)
      end
      allow(collect_block).to receive(:source_location).and_return(["/somewhere/metrics.rb", 25])
      described_class.configure!
      described_class.register_adapter(:test_adapter, adapter)
    end

    after do
      described_class.reset!
      described_class.config.debug = false
    end

    it "calls registered collector" do
      collect!

      expect(adapter).to have_received(:perform_histogram_measure!).with(described_class.test, {}, 42)
    end

    context "when in debug mode" do
      before { described_class.debug! }

      it "calls registered collector" do
        collect!

        expect(adapter).to have_received(:perform_histogram_measure!).with(described_class.test, {}, 42)
      end

      it "measures collector runtime" do
        collect!

        expect(adapter).to have_received(:perform_histogram_measure!).with(
          described_class.yabeda.collect_duration, { location: "/somewhere/metrics.rb:25" }, be_between(0.005, 0.05),
        )
      end
    end
  end
end
