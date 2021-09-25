# frozen_string_literal: true

module Yabeda
  module RSpec
    # Notes:
    #  +expected+ is always a metric instance
    #  +actual+ is always a block of code
    # Example:
    #  expect { anything }.to do_whatever_with_yabeda_metric(Yabeda.something)
    class BaseMatcher < ::RSpec::Matchers::BuiltIn::BaseMatcher
      attr_reader :tags, :metric

      # Specify a scope of labels (tags). Subset of tags can be specified.
      def with_tags(tags)
        @tags = tags
        self
      end

      def initialize(expected)
        @expected = @metric = resolve_metric(expected)
      rescue KeyError
        raise ArgumentError, <<~MSG
          Pass metric name or metric instance to matcher (e.g. `increment_yabeda_counter(Yabeda.metric_name)` or \
          increment_yabeda_counter('metric_name')). Got #{expected.inspect} instead
        MSG
      end

      # RSpec doesn't define this method, but it is more convenient to rely on +match_when_negated+ method presence
      def does_not_match?(actual)
        @actual = actual
        if respond_to?(:match_when_negated)
          match_when_negated(expected, actual)
        else
          !match(expected, actual)
        end
      end

      def supports_block_expectations?
        true
      end

      # Pretty print metric name (expected is expected to always be a Yabeda metric instance)
      def expected_formatted
        "Yabeda.#{[metric.group, metric.name].compact.join('.')}"
      end

      private

      def resolve_metric(instance_or_name)
        return instance_or_name if instance_or_name.is_a? Yabeda::Metric

        Yabeda.metrics.fetch(instance_or_name.to_s)
      end

      # Filter metric changes by tags.
      # If tags specified, treat them as subset of real tags (to avoid bothering with default tags in tests)
      def filter_matching_changes(changes)
        return changes if tags.nil?

        changes.select { |t, _v| t >= tags }
      end
    end
  end
end
