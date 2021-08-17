# frozen_string_literal: true

require "dry-initializer"

module Yabeda
  # Base class for all metrics
  class Metric
    extend Dry::Initializer

    param  :name,                    comment: "Metric name. Use snake_case. E.g. job_runtime"
    option :comment, optional: true, comment: "Documentation string. Required by some adapters."
    option :tags,    optional: true, comment: "Allowed labels to be set. Required by some adapters."
    option :unit,    optional: true, comment: "In which units it is measured. E.g. `seconds`"
    option :per,     optional: true, comment: "Per which unit is measured `unit`. E.g. `call` as in seconds per call"
    option :group,   optional: true, comment: "Category name for grouping metrics"
    option :aggregation, optional: true, comment: "How adapters should aggregate values from different processes"

    # Returns the value for the given label set
    def get(labels = {})
      values[::Yabeda::Tags.build(labels, group)]
    end

    def values
      @values ||= Concurrent::Hash.new
    end

    # Returns allowed tags for metric (with account for global and group-level +default_tags+)
    # @return Array<Symbol>
    def tags
      (Yabeda.groups[group].default_tags.keys + Array(super)).uniq
    end

    def inspect
      "#<#{self.class.name}: #{[@group, @name].compact.join('.')}>"
    end
  end
end
