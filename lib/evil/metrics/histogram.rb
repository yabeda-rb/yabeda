# frozen_string_literal: true

module Evil
  module Metrics
    class Histogram < Metric
      option :buckets

      def measure(tags, value)
        values[tags] = value
        ::Evil::Metrics.adapters.each do |_, adapter|
          adapter.perform_histogram_measure!(self, tags, value)
        end
        value
      end
    end
  end
end
