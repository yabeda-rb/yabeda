# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
