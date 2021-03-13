# frozen_string_literal: true

module Yabeda
  # Growing-only counter
  class Counter < Metric
    def increment(tags, by: 1)
      all_tags = ::Yabeda::Tags.build(tags, group)
      values[all_tags] += by
      ::Yabeda.adapters.each do |_, adapter|
        adapter.perform_counter_increment!(self, all_tags, by)
      end
      values[all_tags]
    end

    def values
      @values ||= Concurrent::Hash.new(0)
    end
  end
end
