# frozen_string_literal: true

require "yabeda/metric"
require "yabeda/counter"
require "yabeda/gauge"
require "yabeda/histogram"

module Yabeda
  module DSL
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def configure(&block)
        class_exec(&block)
        @group = nil
      end

      def collect(&block)
        ::Yabeda.collectors.push(block)
      end

      def group(group_name)
        @group = group_name
      end

      def counter(*args, **kwargs)
        register(Counter.new(*args, **kwargs, group: @group))
      end

      def gauge(*args, **kwargs)
        register(Gauge.new(*args, **kwargs, group: @group))
      end

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
  end
end
