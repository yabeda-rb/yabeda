# frozen_string_literal: true

module Yabeda
  # Arbitrary value, can be changed in both sides
  class Gauge < Metric
    def set(tags, value)
      all_tags = ::Yabeda::Tags.build(tags)
      values[all_tags] = value
      ::Yabeda.adapters.each do |_, adapter|
        adapter.perform_gauge_set!(self, all_tags, value)
      end
      value
    end
  end
end
