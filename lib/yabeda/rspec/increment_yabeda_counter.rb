# frozen_string_literal: true

require_relative "base_matcher"

module Yabeda
  module RSpec
    # Checks whether Yabeda counter was incremented during test run or not
    # @param metric [Yabeda::Counter,String,Symbol] metric instance or name
    # @return [Yabeda::RSpec::IncrementYabedaCounter]
    def increment_yabeda_counter(metric)
      IncrementYabedaCounter.new(metric)
    end

    # Custom matcher class with implementation for +increment_yabeda_counter+
    class IncrementYabedaCounter < BaseMatcher
      def by(increment)
        @expected_increment = increment
        @expectations = { tags => increment } if tags
        self
      end

      attr_reader :expected_increment

      def initialize(*)
        super
        return if metric.is_a? Yabeda::Counter

        raise ArgumentError, "Pass counter instance/name to `increment_yabeda_counter`. Got #{metric.inspect} instead"
      end

      def match(metric, block)
        block.call

        increments = filter_matching_changes(Yabeda::TestAdapter.instance.counters.fetch(metric))

        return false if increments.empty?

        increments.values.all? do |expected_increment, actual_increment|
          next !actual_increment.nil? if expected_increment.nil?

          values_match?(expected_increment, actual_increment)
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

        increments = filter_matching_changes(Yabeda::TestAdapter.instance.counters.fetch(metric))

        increments.none? { |_tags, (_expected, actual)| !actual.nil? }
      end

      def failure_message
        "expected #{expected_formatted} " \
          "to be incremented #{"by #{description_of(expected_increment)} " unless expected_increment.nil?}" \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
          "but #{actual_increments_message}"
      end

      def failure_message_when_negated
        "expected #{expected_formatted} " \
          "not to be incremented " \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
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
