require "yabeda/rspec"

RSpec.describe "Yabeda RSpec matchers" do
  before do
    Yabeda.reset!
    ::Yabeda.configure do
      gauge :test_gauge
      gauge :other_gauge
    end
    Yabeda.register_adapter(:test, Yabeda::TestAdapter.instance)
    Yabeda.configure!
  end

  describe "#update_yabeda_gauge" do
    it "succeeds when given gauge was updated by any value" do
      expect {
        Yabeda.test_gauge.set({}, 42)
      }.to update_yabeda_gauge(Yabeda.test_gauge)
    end

    it "fails when given gauge wasn't updated" do
      expect {
        expect {
          # nothing here
        }.to update_yabeda_gauge(Yabeda.test_gauge)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "fails when any other gauge was updated" do
      expect {
        expect {
          Yabeda.other_gauge.set({}, 42)
        }.to update_yabeda_gauge(Yabeda.test_gauge)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    context "with set specified" do
      it "succeeds when given gauge was updated by exact value" do
        expect {
          Yabeda.test_gauge.set({}, 42)
        }.to update_yabeda_gauge(Yabeda.test_gauge).with(42)
      end

      it "succeeds when given gauge was updated by matching value" do
        expect {
          Yabeda.test_gauge.set({}, 2)
        }.to update_yabeda_gauge(Yabeda.test_gauge).with(be_even)
      end

      it "fails when given gauge was updated with any other value" do
        expect {
          expect {
            Yabeda.other_gauge.set({}, 3)
          }.to update_yabeda_gauge(Yabeda.test_gauge).with(2)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with tags specified" do
      it "succeeds when tags are match" do
        expect {
          Yabeda.test_gauge.set({ foo: :bar }, 42)
        }.to update_yabeda_gauge(Yabeda.test_gauge).with_tags(foo: :bar)
      end

      it "fails when tags doesn't match" do
        expect {
          expect {
            Yabeda.other_gauge.set({ foo: :bar, baz: :qux }, 0)
          }.to update_yabeda_gauge(Yabeda.test_gauge).with_tags(foo: :bar, baz: :boom)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "succeeds when subset of tags was specified and it matches" do
        expect {
          expect {
            Yabeda.other_gauge.set({ foo: :bar, baz: :qux }, 3)
          }.to update_yabeda_gauge(Yabeda.test_gauge).with_tags(foo: :bar)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with negated expect" do
      it "succeeds when given gauge wasn't updated" do
        expect {
          # nothing here
        }.not_to update_yabeda_gauge(Yabeda.test_gauge)
      end

      it "fails when given gauge was updated" do
        expect {
          expect {
            Yabeda.test_gauge.set({}, 42)
          }.not_to update_yabeda_gauge(Yabeda.test_gauge)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      context "with set specified" do
        it "throws error as this behavior can lead to too permissive tests" do
          expect {
            expect {
              Yabeda.test_gauge.set({}, 42)
            }.not_to update_yabeda_gauge(Yabeda.test_gauge).with(42)
          }.to raise_error(NotImplementedError)
        end
      end

      context "with tags specified" do
        it "fails when tags are match" do
          expect {
            expect {
              Yabeda.test_gauge.set({ foo: :bar }, 42)
            }.not_to update_yabeda_gauge(Yabeda.test_gauge).with_tags(foo: :bar)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "succeeds when tags doesn't match" do
          expect {
            Yabeda.test_gauge.set({ foo: :bar, baz: :qux }, 5)
          }.not_to update_yabeda_gauge(Yabeda.test_gauge).with_tags(foo: :bar, baz: :boom)
        end

        it "fails when subset of tags was specified and set tags matches this subset" do
          expect {
            expect {
              Yabeda.test_gauge.set({ foo: :bar, baz: :qux }, 0.001)
            }.not_to update_yabeda_gauge(Yabeda.test_gauge).with_tags(foo: :bar)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end
      end
    end

    it "allows to pass gauge name instead of metric object" do
      expect {
        Yabeda.test_gauge.set({}, 0)
      }.to update_yabeda_gauge(:test_gauge).with(be_zero)
    end
  end
end
