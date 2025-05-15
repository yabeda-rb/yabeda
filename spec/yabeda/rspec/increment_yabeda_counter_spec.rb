# frozen_string_literal: true

require "yabeda/rspec"

RSpec.describe "Yabeda RSpec matchers" do
  before do
    Yabeda.reset!
    Yabeda.configure do
      counter :test_counter
      counter :other_counter
    end
    Yabeda.register_adapter(:test, Yabeda::TestAdapter.instance)
    Yabeda.configure!
  end

  describe "#increment_yabeda_counter" do
    it "succeeds when given counter was incremented by any value" do
      expect do
        Yabeda.test_counter.increment({}, by: 42)
      end.to increment_yabeda_counter(Yabeda.test_counter)
    end

    it "fails when given counter wasn't incremented" do
      expect do
        expect do
          # nothing here
        end.to increment_yabeda_counter(Yabeda.test_counter)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "fails when any other counter was incremented" do
      expect do
        expect do
          Yabeda.other_counter.increment({})
        end.to increment_yabeda_counter(Yabeda.test_counter)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    context "with increment specified" do
      it "succeeds when given counter was incremented by exact value" do
        expect do
          Yabeda.test_counter.increment({}, by: 42)
        end.to increment_yabeda_counter(Yabeda.test_counter).by(42)
      end

      it "succeeds when given counter was incremented by matching value" do
        expect do
          Yabeda.test_counter.increment({}, by: 2)
        end.to increment_yabeda_counter(Yabeda.test_counter).by(be_even)
      end

      it "fails when given counter was incremented with any other value" do
        expect do
          expect do
            Yabeda.test_counter.increment({})
          end.to increment_yabeda_counter(Yabeda.test_counter).by(2)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with tags specified" do
      it "succeeds when tags are match" do
        expect do
          Yabeda.test_counter.increment({ foo: :bar }, by: 42)
        end.to increment_yabeda_counter(Yabeda.test_counter).with_tags(foo: :bar)
      end

      it "fails when tags doesn't match" do
        expect do
          expect do
            Yabeda.test_counter.increment({ foo: :bar, baz: :qux })
          end.to increment_yabeda_counter(Yabeda.test_counter).with_tags(foo: :bar, baz: :boom)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "succeeds when subset of tags was specified and it matches" do
        expect do
          Yabeda.test_counter.increment({ foo: :bar, baz: :qux })
        end.to increment_yabeda_counter(Yabeda.test_counter).with_tags(foo: :bar)
      end
    end

    context "with negated expect" do
      it "succeeds when given counter wasn't incremented" do
        expect do
          # nothing here
        end.not_to increment_yabeda_counter(Yabeda.test_counter)
      end

      it "fails when given counter was incremented" do
        expect do
          expect do
            Yabeda.test_counter.increment({}, by: 42)
          end.not_to increment_yabeda_counter(Yabeda.test_counter)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      context "with increment specified" do
        it "throws error as this behavior can lead to too permissive tests" do
          expect do
            expect do
              Yabeda.test_counter.increment({}, by: 42)
            end.not_to increment_yabeda_counter(Yabeda.test_counter).by(42)
          end.to raise_error(NotImplementedError)
        end
      end

      context "with tags specified" do
        it "fails when tags are match" do
          expect do
            expect do
              Yabeda.test_counter.increment({ foo: :bar }, by: 42)
            end.not_to increment_yabeda_counter(Yabeda.test_counter).with_tags(foo: :bar)
          end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "succeeds when tags doesn't match" do
          expect do
            Yabeda.test_counter.increment({ foo: :bar, baz: :qux })
          end.not_to increment_yabeda_counter(Yabeda.test_counter).with_tags(foo: :bar, baz: :boom)
        end

        it "fails when subset of tags was specified and increment tags matches this subset" do
          expect do
            expect do
              Yabeda.test_counter.increment({ foo: :bar, baz: :qux })
            end.not_to increment_yabeda_counter(Yabeda.test_counter).with_tags(foo: :bar)
          end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end
      end
    end

    it "allows to pass counter name instead of metric object" do
      expect do
        Yabeda.test_counter.increment({}, by: 1)
      end.to increment_yabeda_counter(:test_counter).by(1)
    end

    context "with expectations specified" do
      it "succeeds when all expectations are met" do
        expect do
          Yabeda.test_counter.increment({ tag: :foo }, by: 13)
          Yabeda.test_counter.increment({ tag: :bar }, by: 42)
        end.to increment_yabeda_counter(Yabeda.test_counter).with(
          { tag: :foo } => 13,
          { tag: :bar } => (be >= 42),
        )
      end

      it "fails when some expectations doesn't meet" do
        expect do
          expect do
            Yabeda.test_counter.increment({ tag: :bar }, by: 42)
          end.to increment_yabeda_counter(Yabeda.test_counter).with(
            { tag: :foo } => 13,
            { tag: :bar } => (be >= 42),
          )
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "fails when no expectations are met" do
        expect do
          expect do
            Yabeda.test_counter.increment({ tag: :bar }, by: 13)
          end.to increment_yabeda_counter(Yabeda.test_counter).with(
            { tag: :foo } => 13,
            { tag: :bar } => (be >= 42),
          )
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end
end
