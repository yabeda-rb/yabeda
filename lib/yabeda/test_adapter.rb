# frozen_string_literal: true

require "singleton"

require_relative "./base_adapter"

module Yabeda
  # Fake monitoring system adapter that collects latest metric values for later inspection
  class TestAdapter < BaseAdapter
    include Singleton

    attr_reader :counters, :gauges, :histograms

    def initialize
      @counters   = Hash.new { |ch, ck| ch[ck] = Hash.new { |th, tk| th[tk] = 0 } }
      @gauges     = Hash.new { |gh, gk| gh[gk] = Hash.new { |th, tk| th[tk] = nil } }
      @histograms = Hash.new { |hh, hk| hh[hk] = Hash.new { |th, tk| th[tk] = nil } }
    end

    # Call this method after every test example to quickly get blank state for the next test example
    def reset!
      [@counters, @gauges, @histograms].each do |collection|
        collection.each_value(&:clear) # Reset tag-values hash to be empty
      end
    end

    def register_counter!(metric)
      @counters[metric]
    end

    def register_gauge!(metric)
      @gauges[metric]
    end

    def register_histogram!(metric)
      @histograms[metric]
    end

    def perform_counter_increment!(counter, tags, increment)
      @counters[counter][tags] += increment
    end

    def perform_gauge_set!(gauge, tags, value)
      @gauges[gauge][tags] = value
    end

    def perform_histogram_measure!(histogram, tags, value)
      @histograms[histogram][tags] = value
    end
  end
end
