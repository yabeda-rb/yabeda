# frozen_string_literal: true

module Yabeda
  class Histogram < Metric
    option :buckets

    def measure(tags, value)
      values[tags] = value
      ::Yabeda.adapters.each do |_, adapter|
        adapter.perform_histogram_measure!(self, tags, value)
      end
      value
    end
  end
end
