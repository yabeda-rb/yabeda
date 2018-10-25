# frozen_string_literal: true

require "yabeda/metric"
require "yabeda/counter"
require "yabeda/gauge"
require "yabeda/histogram"

module Yabeda
  # DSL for ease of work with Yabeda
  module DSL
    def self.included(base)
      base.extend ClassMethods
    end

    # rubocop: disable Style/Documentation
    module ClassMethods
      # Block for grouping and simplifying configuration of related metrics
      def configure(&block)
        class_exec(&block)
        @group = nil
      end

      # Define the actions that should be performed
      def collect(&block)
        ::Yabeda.collectors.push(block)
      end

      # Specify metric category or group for all consecutive metrics in this
      # +configure+ block.
      # On most adapters it is only adds prefix to the metric name but on some
      # (like NewRelic) it is treated individually and have special meaning.
      def group(group_name)
        @group = group_name
      end

      # Register a growing-only counter
      def counter(*args, **kwargs)
        register(Counter.new(*args, **kwargs, group: @group))
      end

      # Register a gauge
      def gauge(*args, **kwargs)
        register(Gauge.new(*args, **kwargs, group: @group))
      end

      # Register an histogram
      def histogram(*args, **kwargs)
        register(Histogram.new(*args, **kwargs, group: @group))
      end

      private

      def register(metric)
        name = [metric.group, metric.name].compact.join("_")
        ::Yabeda.define_singleton_method(name) { metric }
        ::Yabeda.metrics[name] = metric
        ::Yabeda.adapters.each do |_, adapter|
          adapter.register!(metric)
        end
        metric
      end
    end
    # rubocop: enable Style/Documentation
  end
end
