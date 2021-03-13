# frozen_string_literal: true

require "dry-initializer"

module Yabeda
  # Represents a set of metrics grouped under the same name
  class Group
    extend Dry::Initializer

    param :name

    def default_tags
      Yabeda::Tags.tag_group(name)
    end

    def register_metric(metric)
      define_singleton_method(metric.name) { metric }
    end
  end
end
