# frozen_string_literal: true

RSpec.describe Yabeda::Summary do
  subject(:observe_summary) { summary.observe(tags, metric_value) }

  let(:tags) { { foo: "bar" } }
  let(:metric_value) { 10 }
  let(:block) { proc { 1 + 1 } }
  let(:summary) { Yabeda.test_summary }
  let(:built_tags) { { built_foo: "built_bar" } }
  let(:adapter) { instance_double(Yabeda::BaseAdapter, perform_summary_observe!: true, register!: true) }

  before { Yabeda.configure! unless Yabeda.already_configured? }

  context "when config has no group" do
    before do
      Yabeda.configure { summary :test_summary }
      allow(Yabeda::Tags).to receive(:build).with(tags, anything).and_return(built_tags)
      Yabeda.register_adapter(:test_adapter, adapter)
    end

    context "with value given" do
      it { is_expected.to eq(metric_value) }

      it "execute perform_summary_observe! method of adapter" do
        observe_summary
        expect(adapter).to have_received(:perform_summary_observe!).with(summary, built_tags, metric_value)
      end
    end

    context "with block given" do
      subject(:observe_summary) { summary.observe(tags, &block) }

      let(:block) { proc { sleep(0.02) } }

      it { is_expected.to be_between(0.01, 0.05) } # Ruby can sleep more or less than requested

      it "execute perform_summary_observe! method of adapter" do
        observe_summary
        expect(adapter).to have_received(:perform_summary_observe!).with(summary, built_tags, be_between(0.01, 0.05))
      end
    end

    context "with both value and block provided" do
      subject(:observe_summary) { summary.observe(tags, metric_value, &block) }

      it "raises an argument error" do
        expect { observe_summary }.to raise_error(ArgumentError)
      end
    end

    context "with both value and block omitted" do
      subject(:observe_summary) { summary.observe(tags) }

      it "raises an argument error" do
        expect { observe_summary }.to raise_error(ArgumentError)
      end
    end
  end

  context "when config contains include_group" do
    before do
      Yabeda.configure do
        group :mushrooms do
          summary :champignon_summary
        end

        adapter :basket_adapter do
          include_group :mushrooms
        end
      end
    end

    let(:tags) { { type: "champignon" } }
    let(:summary) { Yabeda.mushrooms.champignon_summary }

    context "when adapter_name is equal to only_for_adapter" do
      before { Yabeda.register_adapter(:basket_adapter, adapter) }

      it "execute perform_summary_observe! method of adapter" do
        observe_summary
        expect(adapter).to have_received(:perform_summary_observe!).with(summary, tags, metric_value)
      end
    end

    context "when adapter_name is non equal to only_for_adapter" do
      before { Yabeda.register_adapter(:test_adapter, adapter) }

      it "don't execute perform_summary_observe! method of adapter" do
        observe_summary
        expect(adapter).not_to have_received(:perform_summary_observe!).with(summary, tags, metric_value)
      end
    end
  end
end
