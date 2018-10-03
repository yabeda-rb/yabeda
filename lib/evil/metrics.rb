# frozen_string_literal: true

require "concurrent"

require "evil/metrics/version"
require "evil/metrics/dsl"

module Evil
  module Metrics
    include DSL

    cattr_reader :metrics,    default: Concurrent::Hash.new
    cattr_reader :adapters,   default: Concurrent::Hash.new
    cattr_reader :collectors, default: Concurrent::Array.new

    class << self
      # @param [Symbol] name
      # @param [BaseAdapter] instance
      def register_adapter(name, instance)
        adapters[name] = instance
        # NOTE: Pretty sure there is race condition
        metrics.each do |_, metric|
          instance.register!(metric)
        end
      end
    end
  end
end
