# frozen_string_literal: true

require "yabeda/rspec"

RSpec.describe "Yabeda RSpec matchers" do
  before do
    Yabeda.reset!
    Yabeda.configure do
      histogram :test_histogram, buckets: [1, 10, 100]
      histogram :other_histogram, buckets: [1, 10, 100]
    end
    Yabeda.register_adapter(:test, Yabeda::TestAdapter.instance)
    Yabeda.configure!
  end

  describe "#measure_yabeda_histogram" do
    it "succeeds when given histogram was updated by any value" do
      expect do
        Yabeda.test_histogram.measure({}, 42)
      end.to measure_yabeda_histogram(Yabeda.test_histogram)
    end

    it "fails when given histogram wasn't updated" do
      expect do
        expect do
          # nothing here
        end.to measure_yabeda_histogram(Yabeda.test_histogram)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "fails when any other histogram was updated" do
      expect do
        expect do
          Yabeda.other_histogram.measure({}, 0.001)
        end.to measure_yabeda_histogram(Yabeda.test_histogram)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    context "with value specified" do
      it "succeeds when given histogram was updated by exact value" do
        expect do
          Yabeda.test_histogram.measure({}, 42)
        end.to measure_yabeda_histogram(Yabeda.test_histogram).with(42)
      end

      it "succeeds when given histogram was updated by matching value" do
        expect do
          Yabeda.test_histogram.measure({}, 2)
        end.to measure_yabeda_histogram(Yabeda.test_histogram).with(be_even)
      end

      it "fails when given histogram was updated with any other value" do
        expect do
          expect do
            Yabeda.test_histogram.measure({}, 1)
          end.to measure_yabeda_histogram(Yabeda.test_histogram).with(2)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with tags specified" do
      it "succeeds when tags are match" do
        expect do
          Yabeda.test_histogram.measure({ foo: :bar }, 42)
        end.to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
      end

      it "fails when tags doesn't match" do
        expect do
          expect do
            Yabeda.test_histogram.measure({ foo: :bar, baz: :qux }, 15)
          end.to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar, baz: :boom)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "succeeds when subset of tags was specified and it matches" do
        expect do
          Yabeda.test_histogram.measure({ foo: :bar, baz: :qux }, 0.001)
        end.to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
      end
    end

    context "with negated expect" do
      it "succeeds when given histogram wasn't updated" do
        expect do
          # nothing here
        end.not_to measure_yabeda_histogram(Yabeda.test_histogram)
      end

      it "fails when given histogram was updated" do
        expect do
          expect do
            Yabeda.test_histogram.measure({}, 42)
          end.not_to measure_yabeda_histogram(Yabeda.test_histogram)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      context "with set specified" do
        it "throws error as this behavior can lead to too permissive tests" do
          expect do
            expect do
              Yabeda.test_histogram.measure({}, 42)
            end.not_to measure_yabeda_histogram(Yabeda.test_histogram).with(42)
          end.to raise_error(NotImplementedError)
        end
      end

      context "with tags specified" do
        it "fails when tags are match" do
          expect do
            expect do
              Yabeda.test_histogram.measure({ foo: :bar }, 42)
            end.not_to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
          end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "succeeds when tags doesn't match" do
          expect do
            Yabeda.test_histogram.measure({ foo: :bar, baz: :qux }, 5)
          end.not_to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar, baz: :boom)
        end

        it "fails when subset of tags was specified and set tags matches this subset" do
          expect do
            expect do
              Yabeda.test_histogram.measure({ foo: :bar, baz: :qux }, 0.001)
            end.not_to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
          end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end
      end
    end

    it "allows to pass histogram name instead of metric object" do
      expect do
        Yabeda.test_histogram.measure({}, 0.013)
      end.to measure_yabeda_histogram(:test_histogram).with(0.01..0.02)
    end

    context "with expectations specified" do
      it "succeeds when all expectations are met" do
        expect do
          Yabeda.test_histogram.measure({ tag: :foo }, 13.00001)
          Yabeda.test_histogram.measure({ tag: :bar }, 42)
        end.to measure_yabeda_histogram(Yabeda.test_histogram).with(
          { tag: :foo } => be_within(1).of(13),
          { tag: :bar } => (be >= 42),
        )
      end

      it "fails when some expectations doesn't meet" do
        expect do
          expect do
            Yabeda.test_histogram.measure({ tag: :foo }, 13.00001)
            Yabeda.test_histogram.measure({ tag: :bar }, 41)
          end.to measure_yabeda_histogram(Yabeda.test_histogram).with(
            { tag: :foo } => be_within(1).of(13),
            { tag: :bar } => (be >= 42),
          )
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "fails when no expectations are met" do
        expect do
          expect do
            Yabeda.test_histogram.measure({ tag: :foo }, 13.00001)
            Yabeda.test_histogram.measure({ tag: :bar }, 41)
          end.to measure_yabeda_histogram(Yabeda.test_histogram).with(
            { tag: :foo } => 13,
            { tag: :bar } => 42,
          )
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end
end
