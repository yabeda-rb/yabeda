# frozen_string_literal: true

require_relative "./base_matcher"

module Yabeda
  module RSpec
    # Checks whether Yabeda counter was incremented during test run or not
    # @param metric [Yabeda::Counter] metric
    def increment_yabeda_counter(metric)
      IncrementYabedaCounter.new(metric)
    end

    class IncrementYabedaCounter < BaseMatcher
      def by(increment)
        @expected_increment = increment
        self
      end

      attr_reader :expected_increment

      def match(metric, block)
        block.call

        increments = Yabeda::TestAdapter.instance.counters.fetch(metric)

        if tags.nil?
          increments.values.any? { |actual_increment| expected_increment.nil? || values_match?(expected_increment, actual_increment) }
        else
          actual_increment = increments.key?(tags) ? increments.fetch(tags) : increments.find(proc { [] }) { |k, _| k >= tags }[1]
          !actual_increment.nil? && (expected_increment.nil? || values_match?(expected_increment, actual_increment))
        end
      end

      def match_when_negated(metric, block)
        unless expected_increment.nil?
          raise NotImplementedError, <<~MSG
            `expect(Yabeda.metric_name).not_to increment_yabeda_counter` doesn't support specifying increment
             with `.by` as it can lead to false positives.
          MSG
        end

        block.call

        increments = Yabeda::TestAdapter.instance.counters.fetch(metric)

        if tags.nil?
          increments.none?
        else
          increment = increments.key?(tags) ? increments.fetch(tags) : increments.find(proc { [] }) { |k, _v| k >= tags }[1]
          increment.nil?
        end
      end

      def failure_message
        "expected #{expected_formatted} " \
        "to be incremented #{"by #{description_of(expected_increment)} " unless expected_increment.nil?}" \
        "#{("with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags)}" \
        "but #{actual_increments_message}"
      end

      def failure_message_when_negated
        "expected #{expected_formatted} " \
        "not to be incremented " \
        "#{("with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags)}" \
        "but #{actual_increments_message}"
      end

      def actual_increments_message
        counter_increments = Yabeda::TestAdapter.instance.counters.fetch(metric)
        if counter_increments.empty?
          "no increments of this counter have been made"
        elsif tags && counter_increments.key?(tags)
          "has been incremented by #{counter_increments.fetch(tags)}"
        else
          "following increments have been made: #{::RSpec::Support::ObjectFormatter.format(counter_increments)}"
        end
      end
    end
  end
end
