# frozen_string_literal: true

RSpec.describe Yabeda::Metric do
  let(:metric)  { described_class.new(name, **options) }
  let(:name)    { "some_metric" }
  let(:options) { { tags: %i[foo bar] } }

  describe "#get" do
    subject { metric.get(tags) }

    let(:tags) { { foo: "1", bar: "2" } }

    before do
      metric.instance_variable_set(:@values, { tags => 42 })
    end

    it { is_expected.to eq(42) }

    it "returns nil for absent data" do
      expect(metric.get({ whatever: "else" })).to be_nil
    end

    context "when default tags are set" do
      before do
        Yabeda.configure do
          default_tag :bar, "2"
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "returns value with account for default tags values" do
        expect(metric.get({ foo: "1" })).to eq(42)
      end
    end
  end

  describe "#tags" do
    subject { metric.tags }

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
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it { is_expected.to match_array(%i[foo bar baz]) }
    end
  end

  describe "#adapters" do
    subject(:metric_adapters) { metric.adapters }

    let(:adapter_name) { :test_adapter }
    let(:adapter) { instance_double(Yabeda::BaseAdapter, register!: true) }
    let(:another_adapter_name) { :another_test_adapter }
    let(:another_adapter) { instance_double(Yabeda::BaseAdapter, register!: true) }

    before do
      Yabeda.register_adapter(adapter_name, adapter)
      Yabeda.register_adapter(another_adapter_name, another_adapter)
    end

    it "returns default Yabeda adapters by default" do
      expect(metric_adapters.object_id).to eq(Yabeda.adapters.object_id)
    end

    context "when metric has option adapter" do
      let(:options) { { tags: %i[foo bar], adapter: :test_adapter } }

      it "returns only defined in option adapter" do
        aggregate_failures do
          expect(metric_adapters).to eq({
                                          adapter_name => adapter,
                                        })
          expect(metric_adapters.size).to eq(1)
        end
      end

      context "when adapter option is invalid" do
        let(:options) { { tags: %i[foo bar], adapter: :invalid } }

        it "raises error" do
          expect { metric_adapters }.to raise_error(Yabeda::ConfigurationError, /invalid adapter option/)
        end
      end
    end

    context "when metric has no adapter option but group does" do
      let(:options) { { group: :adapter_group } }

      before do
        Yabeda.configure do
          group(:adapter_group) { adapter :test_adapter }
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "returns only adapter defined in group" do
        aggregate_failures do
          expect(metric_adapters).to eq({
                                          adapter_name => adapter,
                                        })
          expect(metric_adapters.size).to eq(1)
        end
      end
    end
  end
end
