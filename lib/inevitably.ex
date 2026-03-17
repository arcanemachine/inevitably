defmodule Inevitably do
  @moduledoc "Retry ExUnit assertions until they pass or a timeout is reached."

  @default_timeout 1_000
  @default_interval 20

  @doc """
  Re-run the given ExUnit assertions until they pass or timeout occurs.

  This form allows the use of per-call options to control retry behavior.

  > #### Tip {: .tip}
  >
  > Retries happen only for `ExUnit.AssertionError`. Any other exception is raised immediately.

  ## Options

    - `:timeout` - Maximum total wait time (in milliseconds)
    - `:interval` - Sleep time between retries (in milliseconds)

  ## Option Precedence

  Option precedence is:

  - Use per-call options (e.g. `eventually timeout: 5000, interval: 25 do ... end`),
  - then use global values set in project config (e.g. in `config/test.exs`),
  - then fall back to this package's built-in defaults (`timeout: 1000`, `interval: 20`)

  ## Examples

      eventually timeout: 100, interval: 5 do
        assert File.exists?("/tmp/ready")
      end
  """
  defmacro eventually(opts, do: block) do
    quote do
      Inevitably.run(
        fn ->
          unquote(block)
        end,
        unquote(opts)
      )
    end
  end

  @doc """
  Re-run the given ExUnit assertions until they pass or time out.

  This macro resolves options (e.g. timeout, interval) from application config (`:inevitably`) and
  then falls back to built-in defaults (timeout: `#{@default_timeout}`, interval:
  `#{@default_interval}`).

  > #### Tip {: .tip}
  >
  > Retries happen only for `ExUnit.AssertionError`. Any other exception is raised immediately.

  ## Configuration example

  Set global defaults in your project's config:

  `config/test.exs`
  ```elixir
  import Config

  config :inevitably, timeout: 2_000, interval: 25
  ```

  ## Examples

      eventually do
        assert Process.whereis(MyApp.Worker)
      end
  """
  defmacro eventually(do: block) do
    quote do
      Inevitably.run(fn ->
        unquote(block)
      end)
    end
  end

  @doc false
  def run(fun, opts \\ []) when is_function(fun, 0) do
    timeout = resolve_option(opts, :timeout, @default_timeout)
    interval = resolve_option(opts, :interval, @default_interval)

    validate_positive_integer!(:timeout, timeout)
    validate_positive_integer!(:interval, interval)

    start_ms = System.monotonic_time(:millisecond)
    do_run(fun, start_ms, timeout, interval)
  end

  defp do_run(fun, start_ms, timeout, interval) do
    fun.()
  rescue
    error in ExUnit.AssertionError ->
      elapsed = System.monotonic_time(:millisecond) - start_ms

      if elapsed >= timeout do
        reraise error, __STACKTRACE__
      else
        remaining = timeout - elapsed
        Process.sleep(min(interval, remaining))
        do_run(fun, start_ms, timeout, interval)
      end
  end

  defp resolve_option(opts, key, default) do
    Keyword.get(opts, key, Application.get_env(:inevitably, key, default))
  end

  defp validate_positive_integer!(_key, value) when is_integer(value) and value > 0, do: :ok

  defp validate_positive_integer!(key, value) do
    raise ArgumentError,
          "#{inspect(key)} must be a positive integer, got: #{inspect(value)}"
  end
end
