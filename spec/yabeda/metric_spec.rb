# frozen_string_literal: true

RSpec.describe Yabeda::Metric do
  describe "#tags" do
    subject { described_class.new(name, options).tags }

    let(:name)    { "some_metric" }
    let(:options) { {} }

    it { is_expected.to eq [] }

    context "when metric tags are set" do
      let(:options) { { tags: %i[foo bar] } }

      it { is_expected.to eq options[:tags] }
    end

    context "when default tags are set" do
      let(:options) { { tags: %i[foo bar] } }

      before do
        Yabeda.configure do
          default_tag :bar, "test"
          default_tag :baz, "qux"
        end
      end

      it { is_expected.to match_array(%i[foo bar baz]) }
    end
  end
end
