# frozen_string_literal: true

require_relative "base_matcher"

module Yabeda
  module RSpec
    # Checks whether Yabeda gauge was set to some value during test run or not
    # @param metric [Yabeda::Gauge,String,Symbol] metric instance or name
    # @return [Yabeda::RSpec::UpdateYabedaGauge]
    def update_yabeda_gauge(metric)
      UpdateYabedaGauge.new(metric)
    end

    # Custom matcher class with implementation for +update_yabeda_gauge+
    class UpdateYabedaGauge < BaseMatcher
      def with(value)
        return super if value.is_a?(Hash)

        @expected_value = value
        self
      end

      attr_reader :expected_value

      def initialize(*)
        super
        return if metric.is_a? Yabeda::Gauge

        raise ArgumentError, "Pass gauge instance/name to `update_yabeda_gauge`. Got #{metric.inspect} instead"
      end

      def match(metric, block)
        block.call

        updates = filter_matching_changes(Yabeda::TestAdapter.instance.gauges.fetch(metric))

        return false if updates.empty?

        updates.values.all? do |expected_update, actual_update|
          next !actual_update.nil? if expected_update.nil?

          expected_update.nil? || values_match?(expected_update, actual_update)
        end
      end

      def match_when_negated(metric, block)
        unless expected_value.nil?
          raise NotImplementedError, <<~MSG
            `expect(Yabeda.metric_name).not_to update_yabeda_gauge` doesn't support specifying values with `.with`
            as it can lead to false positives.
          MSG
        end

        block.call

        updates = filter_matching_changes(Yabeda::TestAdapter.instance.gauges.fetch(metric))

        updates.none? { |_tags, (_expected, actual)| !actual.nil? }
      end

      def failure_message
        "expected #{expected_formatted} " \
          "to be changed #{"to #{expected_value} " unless expected_value.nil?}" \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
          "but #{actual_changes_message}"
      end

      def failure_message_when_negated
        "expected #{expected_formatted} " \
          "not to be changed " \
          "#{"with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags}" \
          "#{if !tags && expectations
               "with following expectations: #{::RSpec::Support::ObjectFormatter.format(expectations)} "
             end}" \
          "but #{actual_changes_message}"
      end

      def actual_changes_message
        updates = Yabeda::TestAdapter.instance.gauges.fetch(metric)
        if updates.empty?
          "no changes of this gauge have been made"
        elsif tags && updates.key?(tags)
          "has been changed to #{updates.fetch(tags)} with tags #{::RSpec::Support::ObjectFormatter.format(tags)}"
        else
          "following changes have been made: #{::RSpec::Support::ObjectFormatter.format(updates)}"
        end
      end
    end
  end
end
