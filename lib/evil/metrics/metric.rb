# frozen_string_literal: true

require "dry-initializer"

module Evil
  module Metrics
    # Base class for all metrics
    class Metric
      extend Dry::Initializer

      param  :name,                    comment: "Metric name. Use snake_case. E.g. job_runtime"
      option :comment, optional: true, comment: "Documentation string. Required by some adapters."
      option :unit,    optional: true, comment: "In which units it is measured. E.g. `seconds`"
      option :per,     optional: true, comment: "Per which unit is measured `unit`. E.g. `call` as in seconds per call"
      option :group,   optional: true, comment: "Category name for grouping metrics"

      # Returns the value for the given label set
      def get(labels = {})
        values[labels]
      end

      def values
        @values ||= Concurrent::Hash.new
      end
    end
  end
end
