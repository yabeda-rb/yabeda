# frozen_string_literal: true

RSpec.describe Yabeda::Tags do
  describe '.build' do
    subject { described_class.build(tags) }

    let(:tags) { { controller: 'foo' } }

    context 'when general tags are not set' do
      it { is_expected.to eq({ controller: 'foo' }) }
    end

    context 'when general tags are set' do
      before do
        Yabeda.configure do
          general_tag :environment, 'test'
        end
      end

      it { is_expected.to eq({ environment: 'test', controller: 'foo' }) }
    end
  end
end
