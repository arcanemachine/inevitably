# Inevitably

`Inevitably` provides an ergonomic `eventually do ... end` macro for ExUnit tests.

It retries the block until assertions pass or a timeout is reached.

## Usage

```elixir
import Inevitably

result =
  eventually do
    value = fetch_value()
    assert value == 42
    value
  end

assert result == 42
```

You can override timeout and interval per call:

```elixir
eventually timeout: 500, interval: 10 do
  assert_ready()
end
```

## Configuration

Set global defaults in `config/config.exs`:

```elixir
config :inevitably,
  timeout: 500,
  interval: 10
```

Option precedence is:
1. per-call options
2. application config
3. built-in defaults (`timeout: 1000`, `interval: 20`)

## Installation

Add `inevitably` to your dependencies:

```elixir
def deps do
  [
    {:inevitably, "~> 0.1.0", only: :test}
  ]
end
```
