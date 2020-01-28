# frozen_string_literal: true

RSpec.describe Yabeda do
  it "has a version number" do
    expect(Yabeda::VERSION).not_to be nil
  end

  it "exposes the public api" do
    expect(described_class.metrics).to eq({})
    expect(described_class.adapters).to eq({})
    expect(described_class.collectors).to eq([])
    expect(described_class.default_tags).to eq({})
    expect(described_class.configured?).to eq(false)
  end

  describe ".configure!" do
    subject(:configure!) { described_class.configure! }

    it { expect { configure! }.to change(described_class, :configured?).to true }

    context "when called multiple times" do
      before { described_class.configure! }

      it { expect { configure! }.to raise_error(Yabeda::AlreadyConfiguredError) }
    end
  end
end
