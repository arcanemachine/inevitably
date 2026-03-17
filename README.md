# Inevitably

`Inevitably` is a simple Elixir test helper that provides an ergonomic `eventually do...end` macro for ExUnit tests.

It retries the block until assertions pass or a timeout is reached.

This package implements the same basic idea as [assert_eventually](https://github.com/rslota/ex_assert_eventually), while providing a more ergonomic block-based interface.

## What's with the name?

It's a close-enough synonym for `eventually`, which is already taken by another Hex project.

## Installation

Add `inevitably` to your dependencies:

`mix.exs`
```elixir
def deps do
  [
    {:inevitably, "~> 0.1.0", only: :test}
  ]
end
```

## Usage

```elixir
import Inevitably

# You can call the macro on its own
eventually do
  assert some_long_task() == 42
end

# You can also get it to return a value
result =
  eventually do
    value = some_long_task()
    assert value == 42

    value
  end

assert result == 42
```

You can override timeout and interval per call:

```elixir
eventually timeout: 500, interval: 10 do
  assert long()
end
```

## Configuration

Set global defaults in your project's config:

`config/test.exs`
```elixir
config :inevitably, timeout: 500, interval: 10
```

These values will now be used as the defaults when calling `eventually` without any custom options.

## Option Precedence

Option precedence is:

1. Use per-call options,
2. Then use global values set in project config,
3. Then fall back to built-in defaults (`timeout: 1000`, `interval: 20`)
