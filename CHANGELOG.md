# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## not released

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

 - Removed accidental dependency from Rails. @dsalahutdinov

## 0.1.1 - 2018-10-17

### Changed

 - Renamed evil-metrics gem to yabeda. @Envek

## 0.1.0 - 2018-10-03

 - Initial release of evil-metrics gem. @Envek

[@Envek]: https://github.com/Envek "Andrey Novikov"
[@asusikov]: https://github.com/asusikov "Alexander Susikov"
