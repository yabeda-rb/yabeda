require_relative './base_matcher'

module Yabeda
  module RSpec
    # Checks whether Yabeda counter was incremented during test run or not
    # @param by [Numeric, ::RSpec::Matchers::BuiltIn::BaseMatcher] expected increment. Default: 1
    def be_incremented(by: nil)
      BeIncremented.new(by)
    end

    class BeIncremented < BaseMatcher
      def match(expected, metric)
        unless metric.is_a? Yabeda::Counter
          raise ArgumentError, "Pass counter instance to expect (e.g. `expect(Yabeda.metric_name).to be_incremented`). Got #{metric.inspect} instead"
        end

        expected ||= 1 # Default increment

        increments = Yabeda::TestAdapter.instance.counters.fetch(metric)

        if tags.nil?
          increments.values.any? { |increment| values_match?(expected, increment)  }
        else
          increment = increments.key?(tags) ? increments.fetch(tags) : increments.find(proc{[]}) { |k, _| k >= tags }[1]
          values_match?(expected, increment)
        end
      end

      def match_when_negated(expected, metric)
        unless metric.is_a? Yabeda::Counter
          raise ArgumentError, "Pass counter instance to expect (e.g. `expect(Yabeda.metric_name).to be_incremented`). Got #{metric.inspect} instead"
        end

        unless expected.nil?
          raise "`expect(Yabeda.metric_name).not_to be_incremented` doesn't support specifying increment as it can lead to false positives"
        end

        counter = Yabeda::TestAdapter.instance.counters.fetch(metric)

        if tags.nil?
          counter.none?
        else
          increment = counter.key?(tags) ? counter.fetch(tags) : counter.find(proc{[]}) { |k, _v| k >= tags }[1]
          increment.nil?
        end
      end

      def failure_message
        "expected #{actual_formatted} " \
        "to be incremented by #{description_of(expected || 1)} " \
        "but #{actual_increments_message}"
      end

      def failure_message_when_negated
        "expected #{actual_formatted} " \
        "not to be incremented " \
        "but #{actual_increments_message}"
      end

      def actual_increments_message
        counter_increments = Yabeda::TestAdapter.instance.counters.fetch(actual)
        if (counter_increments.empty?)
          "no increments of this counter have been made"
        elsif (tags && counter_increments.key?(tags))
          "has been incremented by #{counter_increments.fetch(tags)} with tags #{::RSpec::Support::ObjectFormatter.format(tags)}"
        else
          "following increments have been made: #{::RSpec::Support::ObjectFormatter.format(counter_increments)}"
        end
      end
    end
  end
end
