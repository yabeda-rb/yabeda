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
    # rubocop:disable Layout/LineLength
    option :adapter, optional: true, comment: "Monitoring system adapter to register metric in and report metric values to (other adapters won't be used)"
    # rubocop:enable Layout/LineLength

    # Returns the value for the given label set
    def get(labels = {})
      values[::Yabeda::Tags.build(labels, group)]
    end

    def values
      @values ||= Concurrent::Hash.new
    end

    # Returns allowed tags for metric (with account for global and group-level +default_tags+)
    # @return [Array<Symbol>]
    def tags
      (Yabeda.groups[group].default_tags.keys + Array(super)).uniq
    end

    def inspect
      "#<#{self.class.name}: #{[@group, @name].compact.join('.')}>"
    end

    # Returns the metric adapters
    # @return [Hash<Symbol, Yabeda::BaseAdapter>]
    def adapters
      return ::Yabeda.adapters unless adapter

      @adapters ||= begin
        adapter_names = Array(adapter)
        unknown_adapters = adapter_names - ::Yabeda.adapters.keys

        if unknown_adapters.any?
          raise ConfigurationError,
                "invalid adapter option #{adapter.inspect} in metric #{inspect}"
        end

        ::Yabeda.adapters.slice(*adapter_names)
      end
    end

    # Redefined option reader to get group-level adapter if not set on metric level
    # @api private
    def adapter
      return ::Yabeda.groups[group]&.adapter if @adapter == Dry::Initializer::UNDEFINED

      super
    end
  end
end
