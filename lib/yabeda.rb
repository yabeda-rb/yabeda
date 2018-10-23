# frozen_string_literal: true

require "concurrent"

require "yabeda/version"
require "yabeda/dsl"

module Yabeda
  include DSL

  class << self
    def metrics
      @metrics ||= Concurrent::Hash.new
    end

    def adapters
      @adapters ||= Concurrent::Hash.new
    end

    def collectors
      @collectors ||= Concurrent::Array.new
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
  end
end
