# frozen_string_literal: true

require "yabeda/rspec"

RSpec.describe "Yabeda RSpec matchers" do
  before do
    Yabeda.reset!
    Yabeda.configure do
      summary :test_summary
      summary :other_summary
    end
    Yabeda.register_adapter(:test, Yabeda::TestAdapter.instance)
    Yabeda.configure!
  end

  describe "#observe_yabeda_summary" do
    it "succeeds when given summary was updated by any value" do
      expect do
        Yabeda.test_summary.observe({}, 42)
      end.to observe_yabeda_summary(Yabeda.test_summary)
    end

    it "fails when given summary wasn't updated" do
      expect do
        expect do
          # nothing here
        end.to observe_yabeda_summary(Yabeda.test_summary)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "fails when any other summary was updated" do
      expect do
        expect do
          Yabeda.other_summary.observe({}, 0.001)
        end.to observe_yabeda_summary(Yabeda.test_summary)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    context "with value specified" do
      it "succeeds when given summary was updated by exact value" do
        expect do
          Yabeda.test_summary.observe({}, 42)
        end.to observe_yabeda_summary(Yabeda.test_summary).with(42)
      end

      it "succeeds when given summary was updated by matching value" do
        expect do
          Yabeda.test_summary.observe({}, 2)
        end.to observe_yabeda_summary(Yabeda.test_summary).with(be_even)
      end

      it "fails when given summary was updated with any other value" do
        expect do
          expect do
            Yabeda.other_summary.observe({}, 1)
          end.to observe_yabeda_summary(Yabeda.test_summary).with(2)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with tags specified" do
      it "succeeds when tags are match" do
        expect do
          Yabeda.test_summary.observe({ foo: :bar }, 42)
        end.to observe_yabeda_summary(Yabeda.test_summary).with_tags(foo: :bar)
      end

      it "fails when tags doesn't match" do
        expect do
          expect do
            Yabeda.other_summary.observe({ foo: :bar, baz: :qux }, 15)
          end.to observe_yabeda_summary(Yabeda.test_summary).with_tags(foo: :bar, baz: :boom)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "succeeds when subset of tags was specified and it matches" do
        expect do
          expect do
            Yabeda.other_summary.observe({ foo: :bar, baz: :qux }, 0.001)
          end.to observe_yabeda_summary(Yabeda.test_summary).with_tags(foo: :bar)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with negated expect" do
      it "succeeds when given summary wasn't updated" do
        expect do
          # nothing here
        end.not_to observe_yabeda_summary(Yabeda.test_summary)
      end

      it "fails when given summary was updated" do
        expect do
          expect do
            Yabeda.test_summary.observe({}, 42)
          end.not_to observe_yabeda_summary(Yabeda.test_summary)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      context "with set specified" do
        it "throws error as this behavior can lead to too permissive tests" do
          expect do
            expect do
              Yabeda.test_summary.observe({}, 42)
            end.not_to observe_yabeda_summary(Yabeda.test_summary).with(42)
          end.to raise_error(NotImplementedError)
        end
      end

      context "with tags specified" do
        it "fails when tags are match" do
          expect do
            expect do
              Yabeda.test_summary.observe({ foo: :bar }, 42)
            end.not_to observe_yabeda_summary(Yabeda.test_summary).with_tags(foo: :bar)
          end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "succeeds when tags doesn't match" do
          expect do
            Yabeda.test_summary.observe({ foo: :bar, baz: :qux }, 5)
          end.not_to observe_yabeda_summary(Yabeda.test_summary).with_tags(foo: :bar, baz: :boom)
        end

        it "fails when subset of tags was specified and set tags matches this subset" do
          expect do
            expect do
              Yabeda.test_summary.observe({ foo: :bar, baz: :qux }, 0.001)
            end.not_to observe_yabeda_summary(Yabeda.test_summary).with_tags(foo: :bar)
          end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end
      end
    end

    it "allows to pass summary name instead of metric object" do
      expect do
        Yabeda.test_summary.observe({}, 0.013)
      end.to observe_yabeda_summary(:test_summary).with(0.01..0.02)
    end
  end
end
