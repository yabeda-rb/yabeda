# frozen_string_literal: true

require_relative "base_adapter"

module Yabeda
  # Adapter that discards all metrics. Use when you want to disable metric export
  # (e.g. in development or when no monitoring backend is configured).
  class NullAdapter < BaseAdapter
    def register_counter!(_metric); end

    def perform_counter_increment!(_counter, _tags, _increment); end

    def register_gauge!(_metric); end

    def perform_gauge_set!(_gauge, _tags, _value); end

    def register_histogram!(_metric); end

    def perform_histogram_measure!(_histogram, _tags, _value); end

    def register_summary!(_metric); end

    def perform_summary_observe!(_summary, _tags, _value); end
  end
end
