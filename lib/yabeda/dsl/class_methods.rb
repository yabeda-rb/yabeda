# frozen_string_literal: true

require "yabeda/metric"
require "yabeda/counter"
require "yabeda/gauge"
require "yabeda/histogram"
require "yabeda/summary"
require "yabeda/group"
require "yabeda/global_group"
require "yabeda/dsl/metric_builder"

module Yabeda
  # DSL for ease of work with Yabeda
  module DSL
    module ClassMethods
      # Block for grouping and simplifying configuration of related metrics
      def configure(&block)
        Yabeda.configurators.push([@group, block])
        class_exec(&block) if Yabeda.configured?
        @group = nil
      end

      # Define the actions that should be performed
      def collect(&block)
        ::Yabeda.collectors.push(block)
      end

      # Specify metric category or group for all consecutive metrics in this
      # +configure+ block.
      # On most adapters it is only adds prefix to the metric name but on some
      # (like NewRelic) it is treated individually and has a special meaning.
      def group(group_name)
        @group = group_name
        Yabeda.groups[@group] ||= Yabeda::Group.new(@group)
        return unless block_given?

        yield
        @group = nil
      end

      # Register a growing-only counter
      def counter(*args, **kwargs, &block)
        metric = MetricBuilder.new(Counter).build(args, kwargs, @group, &block)
        register_metric(metric)
      end

      # Register a gauge
      def gauge(*args, **kwargs, &block)
        metric = MetricBuilder.new(Gauge).build(args, kwargs, @group, &block)
        register_metric(metric)
      end

      # Register a histogram
      def histogram(*args, **kwargs, &block)
        metric = MetricBuilder.new(Histogram).build(args, kwargs, @group, &block)
        register_metric(metric)
      end

      # Register a summary
      def summary(*args, **kwargs, &block)
        metric = MetricBuilder.new(Summary).build(args, kwargs, @group, &block)
        register_metric(metric)
      end

      # Add default tag for all metric
      #
      # @param name [Symbol] Name of default tag
      # @param value [String] Value of default tag
      def default_tag(name, value, group: @group)
        if group
          Yabeda.groups[group] ||= Yabeda::Group.new(group)
          Yabeda.groups[group].default_tag(name, value)
        else
          Yabeda.default_tags[name] = value
        end
      end

      # Redefine default tags for a limited amount of time
      # @param tags Hash{Symbol=>#to_s}
      def with_tags(**tags)
        previous_temp_tags = temporary_tags
        Thread.current[:yabeda_temporary_tags] = Thread.current[:yabeda_temporary_tags].merge(tags)
        yield
      ensure
        Thread.current[:yabeda_temporary_tags] = previous_temp_tags
      end

      # Get tags set by +with_tags+
      # @api private
      # @return Hash
      def temporary_tags
        Thread.current[:yabeda_temporary_tags] ||= {}
      end

      # Limit all group metrics to specific adapters only
      #
      # @param adapter_names [Array<Symbol>] Names of adapters to use
      def adapter(*adapter_names, group: @group)
        raise ConfigurationError, "Adapter limitation can't be defined outside of group" unless group

        Yabeda.groups[group] ||= Yabeda::Group.new(group)
        Yabeda.groups[group].adapter(*adapter_names)
      end

      private

      def register_metric(metric)
        name = [metric.group, metric.name].compact.join("_")
        ::Yabeda.define_singleton_method(name) { metric }
        ::Yabeda.metrics[name] = metric
        register_group_for(metric) if metric.group
        metric.adapters.each_value { |adapter| adapter.register!(metric) } if ::Yabeda.configured?
        metric
      end

      def register_group_for(metric)
        group = ::Yabeda.groups[metric.group]

        if group.nil?
          group = Group.new(metric.group)
          ::Yabeda.groups[metric.group] = group
        end

        ::Yabeda.define_singleton_method(metric.group) { group } unless ::Yabeda.respond_to?(metric.group)

        group.register_metric(metric)
      end
    end
  end
end
