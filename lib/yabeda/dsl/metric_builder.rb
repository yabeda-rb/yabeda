# frozen_string_literal: true

require "yabeda/dsl/option_builder"

module Yabeda
  module DSL
    # Handles DSL for working with individual metrics
    class MetricBuilder
      extend Dry::Initializer

      param :metric_klass

      def build(args, kwargs, group, &block)
        options = OptionBuilder.new(metric_klass, kwargs).options_from(&block)
        initialize_metric(args, options, group)
      end

      private

      def initialize_metric(params, options, group)
        metric_klass.new(*params, **options, group: group)
      rescue KeyError => e
        raise ConfigurationError, "#{e.message} for #{metric_klass.name}"
      end
    end
  end
end
