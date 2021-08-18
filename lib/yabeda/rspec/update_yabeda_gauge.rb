# frozen_string_literal: true

require_relative "./base_matcher"

module Yabeda
  module RSpec
    # Checks whether Yabeda gauge was set to some value during test run or not
    def update_yabeda_gauge(metric)
      UpdateYabedaGauge.new(metric)
    end

    class UpdateYabedaGauge < BaseMatcher
      def with(value)
        @expected_value = value
        self
      end

      attr_reader :expected_value

      def match(metric, block)
        block.call

        updates = Yabeda::TestAdapter.instance.gauges.fetch(metric)

        if tags.nil?
          updates.values.any? { |increment| expected_value.nil? || values_match?(expected_value, increment) }
        else
          update = updates.key?(tags) ? updates.fetch(tags) : updates.find(proc { [] }) { |k, _| k >= tags }[1]
          !update.nil? && (expected_value.nil? || values_match?(expected_value, update))
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

        updates = Yabeda::TestAdapter.instance.gauges.fetch(metric)

        if tags.nil?
          updates.none?
        else
          update = updates.key?(tags) ? updates.fetch(tags) : updates.find(proc { [] }) { |k, _v| k >= tags }[1]
          update.nil?
        end
      end

      def failure_message
        "expected #{expected_formatted} " \
        "to be changed #{"to #{expected_value} " unless expected_value.nil?}" \
        "#{("with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags)}" \
        "but #{actual_changes_message}"
      end

      def failure_message_when_negated
        "expected #{expected_formatted} " \
        "not to be changed " \
        "#{("with tags #{::RSpec::Support::ObjectFormatter.format(tags)} " if tags)}" \
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
