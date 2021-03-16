# frozen_string_literal: true

require "dry-initializer"

module Yabeda
  # Represents a set of metrics grouped under the same name
  class Group
    extend Dry::Initializer

    param :name

    def tags
      default_tags.keys
    end

    def default_tags
      @default_tags ||= Concurrent::Hash.new

      if name
        Yabeda.groups[nil].default_tags.merge!(@default_tags)
      else
        @default_tags.dup
      end
    end

    def default_tag(key, value)
      @default_tags ||= Concurrent::Hash.new
      @default_tags[key] = value
    end

    def register_metric(metric)
      define_singleton_method(metric.name) { metric }
    end
  end
end
