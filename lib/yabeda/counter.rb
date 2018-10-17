# frozen_string_literal: true

module Yabeda
  # Growing-only counter
  class Counter < Metric
    def increment(tags, by: 1)
      values[tags] += by
      ::Yabeda.adapters.each do |_, adapter|
        adapter.perform_counter_increment!(self, tags, by)
      end
      values[tags]
    end

    def values
      @values ||= Concurrent::Hash.new(0)
    end
  end
end
