# frozen_string_literal: true

RSpec.describe Yabeda::Tags do
  describe '.build' do
    subject { described_class.build(tags) }

    let(:tags) { { controller: 'foo' } }

    context 'when default tags are not set' do
      before do
        Yabeda.default_tags.clear
      end
      it { is_expected.to eq({ controller: 'foo' }) }
    end

    context 'when default tags are set' do
      before do
        Yabeda.configure do
          default_tag :environment, 'test'
        end
      end

      it { is_expected.to eq({ environment: 'test', controller: 'foo' }) }
    end

    context 'when default tags and passing tags the same' do
      before do
        Yabeda.configure do
          default_tag :controller, 'default'
        end
      end

      it { is_expected.to eq({ controller: 'foo' }) }
    end
  end
end
