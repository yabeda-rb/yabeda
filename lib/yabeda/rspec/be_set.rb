require_relative './base_matcher'

module Yabeda
  module RSpec
    # Checks whether Yabeda gauge was updated during test run or not
    def be_set(to: nil)
      BeSet.new(to)
    end

    class BeSet < BaseMatcher
      def match(expected, metric)
        unless metric.is_a? Yabeda::Gauge
          raise ArgumentError, "Pass gauge instance to expect (e.g. `expect(Yabeda.metric_name).to be_set`). Got #{metric.inspect} instead"
        end

        updates = Yabeda::TestAdapter.instance.gauges.fetch(metric)

        if tags.nil?
          updates.values.any? { |increment| expected.nil? || values_match?(expected, increment)  }
        else
          update = updates.key?(tags) ? updates.fetch(tags) : updates.find(proc{[]}) { |k, _| k >= tags }[1]
          expected.nil? || values_match?(expected, update)
        end
      end

      def match_when_negated(expected, metric)
        unless metric.is_a? Yabeda::Gauge
          raise ArgumentError, "Pass gauge instance to expect (e.g. `expect(Yabeda.metric_name).to be_set`). Got #{metric.inspect} instead"
        end

        unless expected.nil?
          raise "`expect(Yabeda.metric_name).not_to be_set` doesn't support specifying values as it can lead to false positives"
        end

        updates = Yabeda::TestAdapter.instance.counters.fetch(metric)

        if tags.nil?
          updates.none?
        else
          update = updates.key?(tags) ? updates.fetch(tags) : updates.find(proc{[]}) { |k, _v| k >= tags }[1]
          update.nil?
        end
      end

      def failure_message
        "expected #{actual_formatted} " \
        "to be changed #{"to #{expected} " if !expected.nil?}" \
        "but #{actual_changes_message}"
      end

      def failure_message_when_negated
        "expected #{actual_formatted} " \
        "not to be incremented " \
        "but #{actual_changes_message}"
      end

      def actual_changes_message
        updates = Yabeda::TestAdapter.instance.gauges.fetch(metric)
        if (updates.empty?)
          "no changes of this gauge have been made"
        elsif (tags && updates.key?(tags))
          "has been changed to #{updates.fetch(tags)} with tags #{::RSpec::Support::ObjectFormatter.format(tags)}"
        else
          "following changes have been made: #{::RSpec::Support::ObjectFormatter.format(updates)}"
        end
      end
    end
  end
end
