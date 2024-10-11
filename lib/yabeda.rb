# frozen_string_literal: true

require "concurrent"
require "forwardable"

require "yabeda/version"
require "yabeda/config"
require "yabeda/dsl"
require "yabeda/tags"
require "yabeda/errors"

# Extendable framework for collecting and exporting metrics from Ruby apps
module Yabeda
  include DSL

  EMPTY_TAGS = {}.freeze

  class << self
    extend Forwardable

    # @return [Hash<String, Yabeda::Metric>] All registered metrics
    def metrics
      @metrics ||= Concurrent::Hash.new
    end

    # @return [Hash<String, Yabeda::Group>] All registered metrics
    def groups
      @groups ||= Concurrent::Hash.new.tap do |hash|
        hash[nil] = Yabeda::GlobalGroup.new(nil)
      end
    end

    # @return [Hash<Symbol, Yabeda::BaseAdapter>] All loaded adapters
    def adapters
      @adapters ||= Concurrent::Hash.new
    end

    # @return [Array<Proc>] All collectors for periodical retrieving of metrics
    def collectors
      @collectors ||= Concurrent::Array.new
    end

    def config
      @config ||= Config.new
    end

    def_delegators :config, :debug?

    # Execute all collector blocks for periodical retrieval of metrics
    #
    # This method is intended to be used by monitoring systems adapters
    def collect!
      collectors.each do |collector|
        if config.debug?
          yabeda.collect_duration.measure({ location: collector.source_location.join(":") }, &collector)
        else
          collector.call
        end
      end
    end

    # @return [Hash<Symbol, Symbol>] All added global default tags
    def default_tags
      @default_tags ||= Concurrent::Hash.new
    end

    # @param [Symbol] name
    # @param [BaseAdapter] instance
    def register_adapter(name, instance)
      adapters[name] = instance
      # NOTE: Pretty sure there is race condition
      metrics.each_value do |metric|
        next unless metric.adapters.key?(name)

        instance.register!(metric)
      end
    end

    # @return [Array<Proc>] All configuration blocks for postponed setup
    def configurators
      @configurators ||= Concurrent::Array.new
    end

    # @return [Boolean] Whether +Yabeda.configure!+ has been already called
    def configured?
      !@configured_by.nil?
    end
    alias already_configured? configured?

    # Perform configuration: registration of metrics and collector blocks
    # @return [void]
    # rubocop: disable Metrics/MethodLength
    def configure!
      raise(AlreadyConfiguredError, @configured_by) if already_configured?

      debug! if config.debug?

      configurators.each do |(group, block)|
        group group
        class_eval(&block)
        group nil
      end

      # Register metrics in adapters after evaluating all configuration blocks
      # to ensure that all global settings (like default tags) will be applied.
      metrics.each_value do |metric|
        metric.adapters.each_value do |adapter|
          adapter.register!(metric)
        end
      end

      @configured_by = caller_locations(1, 1)[0].to_s
    end

    # Enable and setup service metrics to monitor yabeda performance
    def debug!
      return false if @debug_was_enabled_by # Prevent multiple calls

      config.debug ||= true # Enable debug mode in config if it wasn't enabled from other sources
      @debug_was_enabled_by = caller_locations(1, 1)[0].to_s

      configure do
        group :yabeda

        histogram :collect_duration,
                  tags: %i[location], unit: :seconds,
                  buckets: [0.0001, 0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 30, 60].freeze,
                  comment: "A histogram for the time required to evaluate collect blocks"
      end

      adapters.each_value(&:debug!)

      true
    end

    # Forget all the configuration.
    # For testing purposes as it doesn't rollback changes in adapters.
    # @api private
    def reset!
      default_tags.clear
      adapters.clear
      groups.each_key { |group| singleton_class.send(:remove_method, group) if group && respond_to?(group) }
      @groups = nil
      metrics.each_key { |metric| singleton_class.send(:remove_method, metric) if respond_to?(metric) }
      @metrics = nil
      collectors.clear
      configurators.clear
      @config = Config.new
      instance_variable_set(:@configured_by, nil)
      instance_variable_set(:@debug_was_enabled_by, nil)
    end
    # rubocop: enable Metrics/MethodLength
  end
end

require "yabeda/railtie" if defined?(Rails)
