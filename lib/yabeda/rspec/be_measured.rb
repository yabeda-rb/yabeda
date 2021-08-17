require_relative './base_matcher'

module Yabeda
  module RSpec
    # Checks whether Yabeda histogram was measured during test run or not
    def be_measured(with: nil)
      BeMeasured.new(with)
    end

    class BeMeasured < BaseMatcher
      def match(expected, metric)
        unless metric.is_a? Yabeda::Histogram
          raise ArgumentError, "Pass histogram instance to expect (e.g. `expect(Yabeda.metric_name).to be_set`). Got #{metric.inspect} instead"
        end

        measures = Yabeda::TestAdapter.instance.histograms.fetch(metric)

        if tags.nil?
          measures.values.any? { |increment| expected.nil? || values_match?(expected, increment)  }
        else
          measure = measures.key?(tags) ? measures.fetch(tags) : measures.find(proc{[]}) { |k, _| k >= tags }[1]
          expected.nil? || values_match?(expected, measure)
        end
      end

      def match_when_negated(expected, metric)
        unless metric.is_a? Yabeda::Histogram
          raise ArgumentError, "Pass histogram instance to expect (e.g. `expect(Yabeda.metric_name).to be_set`). Got #{metric.inspect} instead"
        end

        unless expected.nil?
          raise NotImplementedError, "`expect(Yabeda.metric_name).not_to be_measured` doesn't support specifying values as it can lead to false positives"
        end

        measures = Yabeda::TestAdapter.instance.histograms.fetch(metric)

        if tags.nil?
          measures.none?
        else
          measure = measures.key?(tags) ? measures.fetch(tags) : measures.find(proc{[]}) { |k, _v| k >= tags }[1]
          measure.nil?
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
        measures = Yabeda::TestAdapter.instance.histograms.fetch(actual)
        if (measures.empty?)
          "no changes of this gauge have been made"
        elsif (tags && measures.key?(tags))
          "has been changed to #{measures.fetch(tags)} with tags #{::RSpec::Support::ObjectFormatter.format(tags)}"
        else
          "following changes have been made: #{::RSpec::Support::ObjectFormatter.format(measures)}"
        end
      end
    end
  end
end
