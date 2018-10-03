# frozen_string_literal: true

require "evil/metrics/metric"
require "evil/metrics/counter"
require "evil/metrics/gauge"
require "evil/metrics/histogram"

module Evil
  module Metrics
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
          ::Evil::Metrics.collectors.push(block)
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
          ::Evil::Metrics.define_singleton_method(name) { metric }
          ::Evil::Metrics.metrics[name] = metric
          ::Evil::Metrics.adapters.each do |_, adapter|
            adapter.register!(metric)
          end
          metric
        end
      end
    end
  end
end
