# frozen_string_literal: true

require_relative "base_matcher"

module Yabeda
  module RSpec
    # Checks whether Yabeda histogram was measured during test run or not
    # @param metric [Yabeda::Histogram,String,Symbol] metric instance or name
    # @return [Yabeda::RSpec::MeasureYabedaHistogram]
    def measure_yabeda_histogram(metric)
      MeasureYabedaHistogram.new(metric)
    end

    # Custom matcher class with implementation for +measure_yabeda_histogram+
    class MeasureYabedaHistogram < BaseMatcher
      def with(value)
        return super if value.is_a?(Hash)

        @expected_value = value
        self
      end

      attr_reader :expected_value

      def initialize(*)
        super
        return if metric.is_a? Yabeda::Histogram

        raise ArgumentError, "Pass histogram instance/name to `measure_yabeda_histogram`. Got #{metric.inspect} instead"
      end

      def match(metric, block)
        block.call

        measures = filter_matching_changes(Yabeda::TestAdapter.instance.histograms.fetch(metric))

        return false if measures.empty?

        measures.values.all? do |expected_measure, actual_measure|
          next !actual_measure.nil? if expected_measure.nil?

          values_match?(expected_measure, actual_measure)
        end
      end

      def match_when_negated(metric, block)
        unless expected_value.nil?
          raise NotImplementedError, <<~MSG
            `expect {}.not_to measure_yabeda_histogram` doesn't support specifying values with `.with`
            as it can lead to false positives.
          MSG
        end

        block.call

        measures = filter_matching_changes(Yabeda::TestAdapter.instance.histograms.fetch(metric))

        measures.none? { |_tags, (_expected, actual)| !actual.nil? }
      end

      def failure_message
        "expected #{expected_formatted} " \
          "to be changed #{"to #{expected} " unless expected_value.nil?}" \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
          "but #{actual_changes_message}"
      end

      def failure_message_when_negated
        "expected #{expected_formatted} " \
          "not to be incremented " \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
          "but #{actual_changes_message}"
      end

      def actual_changes_message
        measures = Yabeda::TestAdapter.instance.histograms.fetch(metric)
        if measures.empty?
          "no changes of this gauge have been made"
        elsif tags && measures.key?(tags)
          "has been changed to #{measures.fetch(tags)} with tags #{::RSpec::Support::ObjectFormatter.format(tags)}"
        else
          "following changes have been made: #{::RSpec::Support::ObjectFormatter.format(measures)}"
        end
      end
    end
  end
end
