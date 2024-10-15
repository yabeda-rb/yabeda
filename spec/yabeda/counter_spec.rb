# frozen_string_literal: true

RSpec.describe Yabeda::Counter do
  subject(:increment_counter) { counter.increment(tags, by: metric_value) }
  let(:tags) { { foo: "bar" } }
  let(:metric_value) { 10 }
  let(:adapter) { instance_double(Yabeda::BaseAdapter, perform_counter_increment!: true, register!: true) }

  before do
    Yabeda.register_adapter(:test_adapter, adapter)
  end

  context "when config has no group" do
    let(:counter) { Yabeda.test_counter }

    before do
      Yabeda.configure do
        counter :test_counter
      end     
      Yabeda.configure! unless Yabeda.already_configured?
    end

    it { expect(increment_counter).to eq(metric_value) }

    it "increments counter with empty tags if tags are not provided" do
      expect { counter.increment }.to change { counter.values[{}] }.by(1)
    end

    it "execute perform_counter_increment!" do
      increment_counter
      expect(adapter).to have_received(:perform_counter_increment!).with(counter, tags, metric_value)
    end
  end

  context "with adapter option" do
    let(:another_adapter) { instance_double(Yabeda::BaseAdapter, perform_counter_increment!: true, register!: true) }
    let(:counter) { Yabeda.counter_with_adapter }

    before do
      Yabeda.register_adapter(:another_adapter, another_adapter)

      Yabeda.configure do
        counter :counter_with_adapter, adapter: :test_adapter
      end
      Yabeda.configure! unless Yabeda.already_configured?
    end

    it "execute perform_counter_increment! with name :test_adapter" do
      increment_counter

      aggregate_failures do
        expect(adapter).to have_received(:perform_counter_increment!).with(counter, tags, metric_value)
        expect(another_adapter).not_to have_received(:perform_counter_increment!)
      end
    end
  end

  context "with call .adapter method" do
    let(:tags) { { type: "champignon" } }
    let(:counter) { Yabeda.mushrooms.champignon_counter }
    let(:basket_adapter) { instance_double(Yabeda::BaseAdapter, perform_counter_increment!: true, register!: true) }

    before do
      Yabeda.register_adapter(:basket_adapter, basket_adapter)
    end

    context "when call .adapter method in outside of group" do
      before do
        Yabeda.configure do
          group :mushrooms do
            counter :champignon_counter
          end

          adapter :basket_adapter do
            include_group :mushrooms
          end
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "execute perform_counter_increment! with name :basket_adapter" do
        increment_counter
  
        aggregate_failures do
          expect(basket_adapter).to have_received(:perform_counter_increment!).with(counter, tags, metric_value)
          expect(adapter).not_to have_received(:perform_counter_increment!)
        end
      end
    end

    context "when call .adapter_names without adapter_names args" do
      it "raises an error" do
        expect do
          Yabeda.configure do
            group :mushrooms do
              counter :champignon_counter
            end

            adapter do
              include_group :mushrooms
            end
          end
          Yabeda.configure! unless Yabeda.already_configured?
        end.to raise_error(Yabeda::ConfigurationError, "Adapter limitation can't be defined without adapter_names")
      end
    end

    context "when call adapter method in inside of group" do
      before do
        Yabeda.configure do
          group :mushrooms do
            adapter :basket_adapter
            counter :champignon_counter
          end
        end
        Yabeda.configure! unless Yabeda.already_configured?
      end

      it "execute perform_counter_increment! with name :basket_adapter" do
        increment_counter
  
        aggregate_failures do
          expect(basket_adapter).to have_received(:perform_counter_increment!).with(counter, tags, metric_value)
          expect(adapter).not_to have_received(:perform_counter_increment!)
        end
      end
    end

    context "when call .adapter_names without adapter_names args" do
      it "raises an error" do
        expect do
          Yabeda.configure do
            group :mushrooms do
              adapter
              counter :champignon_counter
            end
          end
          Yabeda.configure! unless Yabeda.already_configured?
        end.to raise_error(Yabeda::ConfigurationError, "Adapter limitation can't be defined without adapter_names")
      end
    end
  end
end
