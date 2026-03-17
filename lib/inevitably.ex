defmodule Inevitably do
  @moduledoc """
  Retry ExUnit assertions until they pass or a timeout is reached.
  """

  @default_timeout 1_000
  @default_interval 20

  defmacro eventually(do: block) do
    quote do
      Inevitably.run(fn ->
        unquote(block)
      end)
    end
  end

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
