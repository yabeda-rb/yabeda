# frozen_string_literal: true

module Yabeda
  # Growing-only counter
  class Counter < Metric
    # @overload increment(tags = {}, by: 1)
    #   Increment the counter for given set of tags by the given increment value
    #   @param tags Hash{Symbol=>#to_s} tags to identify the counter
    #   @param by [Integer] strictly positive increment value
    def increment(*args)
      tags, by = self.class.parse_args(*args)
      all_tags = ::Yabeda::Tags.build(tags, group)
      values[all_tags] += by
      adapters.each_value do |adapter|
        adapter.perform_counter_increment!(self, all_tags, by)
      end
      values[all_tags]
    end

    def values
      @values ||= Concurrent::Hash.new(0)
    end

    # @api private
    # rubocop:disable Metrics/MethodLength
    def self.parse_args(*args)
      case args.size
      when 0 # increment()
        [EMPTY_TAGS, 1]
      when 1 # increment(by: 5) or increment(tags)
        if args[0].key?(:by)
          [EMPTY_TAGS, args.fetch(:by)]
        else
          [args[0], 1]
        end
      when 2 # increment(tags, by: 5)
        [args[0], args[1].fetch(:by, 1)]
      else
        raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 0..2)"
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
