# frozen_string_literal: true

module Yabeda
  # Base class for complex metric for measuring time values that allow to
  # calculate averages, percentiles, and so on.
  class Summary < Metric
    # rubocop: disable Metrics/MethodLength
    def observe(tags = {}, value = nil)
      if value.nil? ^ block_given?
        raise ArgumentError, "You must provide either numeric value or block for Yabeda::Summary#observe!"
      end

      if block_given?
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        yield
        value = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting)
      end

      all_tags = ::Yabeda::Tags.build(tags, group)
      values[all_tags] = value
      adapters.each_value do |adapter|
        adapter.perform_summary_observe!(self, all_tags, value)
      end
      value
    end
    # rubocop: enable Metrics/MethodLength
  end
end
