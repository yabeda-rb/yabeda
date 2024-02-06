# frozen_string_literal: true

require_relative "base_matcher"

module Yabeda
  module RSpec
    # Checks whether Yabeda summary was observed during test run or not
    # @param metric [Yabeda::Summary,String,Symbol] metric instance or name
    # @return [Yabeda::RSpec::ObserveYabedaSummary]
    def observe_yabeda_summary(metric)
      ObserveYabedaSummary.new(metric)
    end

    # Custom matcher class with implementation for +observe_yabeda_summary+
    class ObserveYabedaSummary < BaseMatcher
      def with(value)
        return super if value.is_a?(Hash)

        @expected_value = value
        self
      end

      attr_reader :expected_value

      def initialize(*)
        super
        return if metric.is_a? Yabeda::Summary

        raise ArgumentError, "Pass summary instance/name to `observe_yabeda_summary`. Got #{metric.inspect} instead"
      end

      def match(metric, block)
        block.call

        observations = filter_matching_changes(Yabeda::TestAdapter.instance.summaries.fetch(metric))

        return false if observations.empty?

        observations.values.all? do |expected_observation, actual_observation|
          next !actual_observation.nil? if expected_observation.nil?

          values_match?(expected_observation, actual_observation)
        end
      end

      def match_when_negated(metric, block)
        unless expected_value.nil?
          raise NotImplementedError, <<~MSG
            `expect {}.not_to observe_yabeda_summary` doesn't support specifying values with `.with`
            as it can lead to false positives.
          MSG
        end

        block.call

        observations = filter_matching_changes(Yabeda::TestAdapter.instance.summaries.fetch(metric))

        observations.none? { |_tags, (_expected, actual)| !actual.nil? }
      end

      def failure_message
        "expected #{expected_formatted} " \
          "to be observed #{"with #{expected} " unless expected_value.nil?}" \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
          "but #{actual_changes_message}"
      end

      def failure_message_when_negated
        "expected #{expected_formatted} " \
          "not to be observed " \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
          "but #{actual_changes_message}"
      end

      def actual_changes_message
        observations = Yabeda::TestAdapter.instance.summaries.fetch(metric)
        if observations.empty?
          "no observations of this summary have been made"
        elsif tags && observations.key?(tags)
          formatted_tags = ::RSpec::Support::ObjectFormatter.format(tags)
          "has been observed with #{observations.fetch(tags)} with tags #{formatted_tags}"
        else
          "following observations have been made: #{::RSpec::Support::ObjectFormatter.format(observations)}"
        end
      end
    end
  end
end
