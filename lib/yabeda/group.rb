# frozen_string_literal: true

require "dry-initializer"

module Yabeda
  # Represents a set of metrics grouped under the same name
  class Group
    extend Dry::Initializer

    param :name

    def default_tags
      @default_tags ||= Concurrent::Hash.new
      ::Yabeda.default_tags.merge(@default_tags)
    end

    def default_tag(key, value)
      @default_tags ||= Concurrent::Hash.new
      @default_tags[key] = value
    end

    def adapter(*adapter_names)
      return @adapter if adapter_names.empty?

      @adapter ||= Concurrent::Array.new
      @adapter.push(*adapter_names)
    end

    def only(*metric_names)
      return @only_list if metric_names.empty?

      @only_list ||= Concurrent::Array.new
      @only_list.push(*metric_names.map(&:to_sym))
    end

    def except(*metric_names)
      return @except_list if metric_names.empty?

      @except_list ||= Concurrent::Array.new
      @except_list.push(*metric_names.map(&:to_sym))
    end

    def register_metric(metric)
      define_singleton_method(metric.name) { metric }
    end
  end
end
