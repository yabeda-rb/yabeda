# frozen_string_literal: true

module Yabeda
  # Growing-only counter
  class Counter < Metric
    def increment(tags, by: 1)
      all_tags = ::Yabeda::Tags.build(tags, group)
      values[all_tags] += by
      ::Yabeda.adapters.each do |adapter_name, adapter|
        adapter.perform_counter_increment!(self, all_tags, by) if can_access_for_adapter?(adapter_name)
      end
      values[all_tags]
    end

    def values
      @values ||= Concurrent::Hash.new(0)
    end
  end
end
