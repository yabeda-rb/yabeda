# frozen_string_literal: true

RSpec.describe Yabeda do
  it "has a version number" do
    expect(Yabeda::VERSION).not_to be nil
  end

  it 'exposes the public api' do
    expect(Yabeda.metrics).to eq({})
    expect(Yabeda.adapters).to eq({})
    expect(Yabeda.collectors).to eq([])
  end
end
