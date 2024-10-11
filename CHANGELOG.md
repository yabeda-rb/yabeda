# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

## 0.13.1 - 2024-10-11

### Fixed

- Compatibility with Ruby 2.x, broken in 0.13.0 due to differences of keywords handling in Ruby 2.x for case when method has arguments with default values. [@Envek]

## 0.13.0 - 2024-10-02

### Added

- Ability to limit some metrics to specific adapters. [#37](https://github.com/yabeda-rb/yabeda/pull/37) by [@Keallar] and [@Envek]

  ```ruby
  Yabeda.configure do
    group :cloud do
      adapter :newrelic, :datadog

      counter :foo
    end

    counter :bar, adapter: :prometheus
  end
  ```

- Multiple expectations in RSpec matchers. [@Envek]

  ```ruby
  expect { whatever }.to increment_yabeda_counter(:my_counter).with(
    { tag: "foo" } => 1,
    { tag: "bar" } => (be >= 42),
  )
  ```

### Changed

- Don't require to provide tags for counters and histograms, use empty tags (`{}`) by default. See discussion at [#26](https://github.com/yabeda-rb/yabeda/issues/26). [@Envek]

  ```ruby
  Yabeda.foo.increment
  # same as
  Yabeda.foo.increment({}, by: 1)
  ```

### Fixed

- Railtie loading to prevent calling methods that have not yet been defined. [#38](https://github.com/yabeda-rb/yabeda/pull/38) by [@bibendi].

## 0.12.0 - 2023-07-28

### Added

- Summary metric type (mostly for Prometheus adapter).

## 0.11.0 - 2021-09-25

### Added

- RSpec matchers `increment_yabeda_counter`, `update_yabeda_gauge`, and `measure_yabeda_histogram` for convenient testing. [#25](https://github.com/yabeda-rb/yabeda/pull/25) by [@Envek][]
- Automatic setup of RSpec on `require "yabeda/rspec"`
- Special test adapter that collects metric changes in memory

## 0.10.1 - 2021-08-30

### Fixed

- Compatibility with anyway_config 1.x gem (which is automatically used on older Rubies, older then minimal Ruby 2.5 for anyway_config 2.x)

## 0.10.0 - 2021-07-21

### Added

- Ability to pass a block to `Yabeda::Histogram#measure` to automatically measure its runtime in seconds using [monotonic time](https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/).
- Debug mode that will enable some additional metrics to help debug performance issues with your usage of Yabeda (or Yabeda itself). Use environment variable `YABEDA_DEBUG` to enable it or call `Yabeda.debug!`.
- Debugging histogram `yabeda_collect_duration` that measures duration of every collect block, as they are used for collecting metrics of application state and usually makes some potentially slow queries to databases, network requests, etc.

### Changed

- Adapters now should use method `Yabeda.collect!` instead of manual calling of every collector block.

## 0.9.0 - 2021-05-07

### Added

- Ability to set global metric tags only for a specific group [#19](https://github.com/yabeda-rb/yabeda/pull/19) by [@liaden]

## 0.8.0 - 2020-08-21

### Added

 - Added railtie to automatically configure Yabeda on Rails: moved from [yabeda-rails](https://github.com/yabeda-rb/yabeda-rails) gem. [@Envek]

## 0.7.0 - 2020-08-07

### Added

 - `#increment` and `#decrement` convenience methods for `Yabeda::Gauge`. [#13](https://github.com/yabeda-rb/yabeda/pull/13) by [@dsalahutdinov]
 - Ability to use custom step in `#increment` and `#decrement` for gauges. [@Envek]

### Fixed

 - Account for default tags in `Yabeda::Metric#get`. [@Envek]

## 0.6.2 - 2020-08-04

### Fixed

 - Compatibility with plugins (like [yabeda-puma-plugin](https://github.com/yabeda-rb/yabeda-puma-plugin)) that for some reason configures itself after Yabeda configuration was already applied by `Yabeda.configure!` (was broken in 0.6.0). [@Envek]

## 0.6.1 - 2020-07-16

### Fixed

 - Compatibility with Ruby < 2.6 due to usage of [new `Hash#merge(*others)` with multiple arguments](https://rubyreferences.github.io/rubychanges/2.6.html#hashmerge-with-multiple-arguments) in 0.6.0. [@Envek]

## 0.6.0 - 2020-07-15

### Added

 - `Yabeda.with_tags` to redefine default tags for limited amount of time–for all metrics measured during a block execution. [@Envek]

### Fixed

 - Default tags were not sent to adapters for metrics declared before `default_tag` declaration. [@Envek]

## 0.5.0 - 2020-01-29

### Added

 - Ability to specify aggregation policy for metrics collected from multiple process and exposed via single endpoint. [@Envek]

   For now it is only used by yabeda-prometheus when official Prometheus client is configured to use file storage for metrics.

## 0.4.0 - 2020-01-28

### Changed

 - Configuration of gem was changed from synchronous (at the moment when `configure` block was executed) to postponed (only on `configure!` method call). [@Envek]

   This should allow to fix problems when metrics from gems are registered too early, before required changes to the monitoring system clients.

## 0.3.0 - 2020-01-15

### Added

 - Ability to specify default tag which value will be automatically added to all metrics. [#7](https://github.com/yabeda-rb/yabeda/pull/7) by [@asusikov].

## 0.2.0 - 2020-01-14

### Added

 - Ability to specify an optional list of allowed `tags` as an option to metric declaration. @Envek

   Some monitoring systems clients (like official prometheus client for Ruby) require to declare all possible metric labels upfront.

## 0.1.3 - 2018-12-18

### Added

 - Block-based DSL for defining groups and metrics. @DmitryTsepelev

## 0.1.2 - 2018-10-25

### Fixed

 - Removed accidental dependency from Rails. [@dsalahutdinov]

## 0.1.1 - 2018-10-17

### Changed

 - Renamed evil-metrics gem to yabeda. @Envek

## 0.1.0 - 2018-10-03

 - Initial release of evil-metrics gem. @Envek

[@Envek]: https://github.com/Envek "Andrey Novikov"
[@dsalahutdinov]: https://github.com/dsalahutdinov "Dmitry Salahutdinov"
[@asusikov]: https://github.com/asusikov "Alexander Susikov"
[@liaden]: https://github.com/liaden "Joel Johnson"
[@bibendi]: https://github.com/bibendi "Misha Merkushin"
[@Keallar]: https://github.com/Keallar "Eugene Lysanskiy"
