# frozen_string_literal: true

require "concurrent"

require "yabeda/version"
require "yabeda/dsl"
require "yabeda/tags"
require "yabeda/errors"

# Extendable framework for collecting and exporting metrics from Ruby apps
module Yabeda
  include DSL

  class << self
    # @return [Hash<String, Yabeda::Metric>] All registered metrics
    def metrics
      @metrics ||= Concurrent::Hash.new
    end

    # @return [Hash<String, Yabeda::Group>] All registered metrics
    def groups
      @groups ||= Concurrent::Hash.new
    end

    # @return [Hash<String, Yabeda::BaseAdapter>] All loaded adapters
    def adapters
      @adapters ||= Concurrent::Hash.new
    end

    # @return [Array<Proc>] All collectors for periodical retrieving of metrics
    def collectors
      @collectors ||= Concurrent::Array.new
    end

    # @return [Hash<Symbol, Symbol>] All added default tags
    def default_tags
      @default_tags ||= Concurrent::Hash.new
    end

    # @param [Symbol] name
    # @param [BaseAdapter] instance
    def register_adapter(name, instance)
      adapters[name] = instance
      # NOTE: Pretty sure there is race condition
      metrics.each do |_, metric|
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
    # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
    def configure!
      raise(AlreadyConfiguredError, @configured_by) if already_configured?

      configurators.each do |(group, block)|
        group group
        class_eval(&block)
        group nil
      end

      # Register metrics in adapters after evaluating all configuration blocks
      # to ensure that all global settings (like default tags) will be applied.
      adapters.each_value do |adapter|
        metrics.each_value do |metric|
          adapter.register!(metric)
        end
      end

      @configured_by = caller_locations(1, 1)[0].to_s
    end
    # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

    # Forget all the configuration.
    # For testing purposes as it doesn't rollback changes in adapters.
    # @api private
    def reset!
      default_tags.clear
      adapters.clear
      groups.clear
      metrics.clear
      collectors.clear
      configurators.clear
      instance_variable_set(:@configured_by, nil)
    end
  end
end
