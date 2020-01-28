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

    # Forget all the configuration.
    # For testing purposes as it doesn't rollback changes in adapters.
    # @api private
    def reset!
      default_tags.clear
      adapters.clear
      groups.clear
      metrics.clear
      collectors.clear
      instance_variable_set(:@configured_by, nil)
    end
  end
end
