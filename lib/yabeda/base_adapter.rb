# frozen_string_literal: true

module Yabeda
  # Base class for adapters to particular monitoring systems
  class BaseAdapter
    def register!(metric)
      case metric
      when Counter   then register_counter!(metric)
      when Gauge     then register_gauge!(metric)
      when Histogram then register_histogram!(metric)
      when Summary   then register_summary!(metric)
      else raise "#{metric.class} is unknown metric type"
      end
    end

    def register_counter!(_metric)
      raise NotImplementedError, "#{self.class} doesn't support counters as metric type!"
    end

    def perform_counter_increment!(_counter, _tags, _increment)
      raise NotImplementedError, "#{self.class} doesn't support incrementing counters"
    end

    def register_gauge!(_metric)
      raise NotImplementedError, "#{self.class} doesn't support gauges as metric type!"
    end

    def perform_gauge_set!(_metric, _tags, _value)
      raise NotImplementedError, "#{self.class} doesn't support setting gauges"
    end

    def register_histogram!(_metric)
      raise NotImplementedError, "#{self.class} doesn't support histograms as metric type!"
    end

    def perform_histogram_measure!(_metric, _tags, _value)
      raise NotImplementedError, "#{self.class} doesn't support measuring histograms"
    end

    def register_summary!(_metric)
      raise NotImplementedError, "#{self.class} doesn't support summaries as metric type!"
    end

    def perform_summary_observe!(_metric, _tags, _value)
      raise NotImplementedError, "#{self.class} doesn't support observing summaries"
    end

    # Hook to enable debug mode in adapters when it is enabled in Yabeda itself
    def debug!; end
  end
end
