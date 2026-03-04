# frozen_string_literal: true

module Yabeda
  # Arbitrary value, can be changed in both sides
  class Gauge < Metric
    def set(tags, value)
      all_tags = ::Yabeda::Tags.build(tags, group)
      atomic_value = values[all_tags] ||= Concurrent::Atom.new(0)
      atomic_value.swap { |_| value }
      adapters.each_value do |adapter|
        adapter.perform_gauge_set!(self, all_tags, value)
      end
      value
    end

    # @overload increment(tags = {}, by: 1)
    #   Convenience method to increment current gauge value for given set of tags by the given increment value
    #   @param tags Hash{Symbol=>#to_s} tags to identify the gauge
    #   @param by [Integer] increment value
    def increment(*args)
      tags, by = Counter.parse_args(*args)
      all_tags = ::Yabeda::Tags.build(tags, group)
      next_value = increment_value(all_tags, by: by)
      adapters.each_value do |adapter|
        if adapter.perform_gauge_increment!(self, all_tags, by).nil?
          adapter.perform_gauge_set!(self, all_tags, next_value)
        end
      end
      next_value
    end

    # @overload decrement(tags = {}, by: 1)
    #   Convenience method to decrement current gauge value for given set of tags by the given decrement value
    #   @param tags Hash{Symbol=>#to_s} tags to identify the gauge
    #   @param by [Integer] decrement value
    def decrement(*args)
      tags, by = Counter.parse_args(*args)
      all_tags = ::Yabeda::Tags.build(tags, group)
      next_value = increment_value(all_tags, by: -by)
      adapters.each_value do |adapter|
        if adapter.perform_gauge_increment!(self, all_tags, -by).nil?
          adapter.perform_gauge_set!(self, all_tags, next_value)
        end
      end
      next_value
    end
  end
end
