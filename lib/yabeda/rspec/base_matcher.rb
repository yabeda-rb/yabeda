module Yabeda
  module RSpec
    class BaseMatcher < ::RSpec::Matchers::BuiltIn::BaseMatcher
      attr_reader :tags, :metric

      def with_tags(tags)
        @tags = tags
        self
      end

      def matches?(actual)
        unless actual.is_a? Yabeda::Metric
          raise ArgumentError, "Pass metric instance to expect (e.g. `expect(Yabeda.metric_name)`). Got #{actual.inspect} instead"
        end
        @metric = @actual = actual
        match(expected, actual)
      end

      def does_not_match?(actual)
        unless actual.is_a? Yabeda::Metric
          raise ArgumentError, "Pass metric instance to expect (e.g. `expect(Yabeda.metric_name)`). Got #{actual.inspect} instead"
        end
        @metric = @actual = actual
        if respond_to?(:match_when_negated)
          match_when_negated(expected, actual)
        else
          !match(expected, actual)
        end
      end

      # Pretty print metric name (actual is expected to be a Yabeda metric instance)
      def actual_formatted
        "Yabeda.#{[metric.group, metric.name].compact.join('.')}"
      end
    end
  end
end
