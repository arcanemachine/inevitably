# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-16

### Added

- Initial release of `Inevitably`.
- `eventually do ... end` macro for retrying `ExUnit` assertions until success or timeout.
- Per-call options for `timeout` and `interval`.
- Global configuration support via `config :inevitably, timeout: ..., interval: ...`.
- Option precedence: per-call options, then app config, then built-in defaults.
- Validation that `timeout` and `interval` must be positive integers.
- Async compatibility coverage in tests.
