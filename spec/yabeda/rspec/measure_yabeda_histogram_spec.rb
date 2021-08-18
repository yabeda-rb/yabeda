require "yabeda/rspec"

RSpec.describe "Yabeda RSpec matchers" do
  before do
    Yabeda.reset!
    ::Yabeda.configure do
      histogram :test_histogram, buckets: [1, 10, 100]
      histogram :other_histogram, buckets: [1, 10, 100]
    end
    Yabeda.register_adapter(:test, Yabeda::TestAdapter.instance)
    Yabeda.configure!
  end

  describe "#measure_yabeda_histogram" do
    it "succeeds when given histogram was updated by any value" do
      expect {
        Yabeda.test_histogram.measure({}, 42)
      }.to measure_yabeda_histogram(Yabeda.test_histogram)
    end

    it "fails when given histogram wasn't updated" do
      expect {
        expect {
          # nothing here
        }.to measure_yabeda_histogram(Yabeda.test_histogram)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "fails when any other histogram was updated" do
      expect {
        expect {
          Yabeda.other_histogram.measure({}, 0.001)
        }.to measure_yabeda_histogram(Yabeda.test_histogram)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    context "with value specified" do
      it "succeeds when given histogram was updated by exact value" do
        expect {
          Yabeda.test_histogram.measure({}, 42)
        }.to measure_yabeda_histogram(Yabeda.test_histogram).with(42)
      end

      it "succeeds when given histogram was updated by matching value" do
        expect {
          Yabeda.test_histogram.measure({}, 2)
        }.to measure_yabeda_histogram(Yabeda.test_histogram).with(be_even)
      end

      it "fails when given histogram was updated with any other value" do
        expect {
          expect {
            Yabeda.other_histogram.measure({}, 1)
          }.to measure_yabeda_histogram(Yabeda.test_histogram).with(2)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with tags specified" do
      it "succeeds when tags are match" do
        expect {
          Yabeda.test_histogram.measure({ foo: :bar }, 42)
        }.to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
      end

      it "fails when tags doesn't match" do
        expect {
          expect {
            Yabeda.other_histogram.measure({ foo: :bar, baz: :qux }, 15)
          }.to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar, baz: :boom)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "succeeds when subset of tags was specified and it matches" do
        expect {
          expect {
            Yabeda.other_histogram.measure({ foo: :bar, baz: :qux }, 0.001)
          }.to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with negated expect" do
      it "succeeds when given histogram wasn't updated" do
        expect {
          # nothing here
        }.not_to measure_yabeda_histogram(Yabeda.test_histogram)
      end

      it "fails when given histogram was updated" do
        expect {
          expect {
            Yabeda.test_histogram.measure({}, 42)
          }.not_to measure_yabeda_histogram(Yabeda.test_histogram)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      context "with set specified" do
        it "throws error as this behavior can lead to too permissive tests" do
          expect {
            expect {
              Yabeda.test_histogram.measure({}, 42)
            }.not_to measure_yabeda_histogram(Yabeda.test_histogram).with(42)
          }.to raise_error(NotImplementedError)
        end
      end

      context "with tags specified" do
        it "fails when tags are match" do
          expect {
            expect {
              Yabeda.test_histogram.measure({ foo: :bar }, 42)
            }.not_to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "succeeds when tags doesn't match" do
          expect {
            Yabeda.test_histogram.measure({ foo: :bar, baz: :qux }, 5)
          }.not_to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar, baz: :boom)
        end

        it "fails when subset of tags was specified and set tags matches this subset" do
          expect {
            expect {
              Yabeda.test_histogram.measure({ foo: :bar, baz: :qux }, 0.001)
            }.not_to measure_yabeda_histogram(Yabeda.test_histogram).with_tags(foo: :bar)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end
      end
    end

    it "allows to pass histogram name instead of metric object" do
      expect {
        Yabeda.test_histogram.measure({}, 0.013)
      }.to measure_yabeda_histogram(:test_histogram).with(0.01..0.02)
    end
  end
end
