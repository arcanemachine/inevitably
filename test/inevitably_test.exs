defmodule InevitablyTest do
  use ExUnit.Case, async: false

  import Inevitably

  setup do
    original_timeout = Application.get_env(:inevitably, :timeout)
    original_interval = Application.get_env(:inevitably, :interval)

    on_exit(fn ->
      restore_env(:timeout, original_timeout)
      restore_env(:interval, original_interval)
    end)

    :ok
  end

  test "returns the last expression from the block" do
    result =
      eventually timeout: 50, interval: 1 do
        value = 42
        assert value == 42
        value
      end

    assert result == 42
  end

  test "retries assertion failures until success" do
    Process.put(:attempt, 0)

    result =
      eventually timeout: 100, interval: 1 do
        attempt = Process.get(:attempt, 0) + 1
        Process.put(:attempt, attempt)

        assert attempt >= 3
        :ok
      end

    assert result == :ok
    assert Process.get(:attempt) == 3
  end

  test "re-raises the last assertion error after timeout" do
    error =
      assert_raise ExUnit.AssertionError, fn ->
        eventually timeout: 30, interval: 1 do
          expected = :ok
          actual = Process.get(:actual_value, :error)
          assert expected == actual
        end
      end

    assert error.left == :ok
    assert error.right == :error
  end

  test "uses global application config when per-call options are not provided" do
    Application.put_env(:inevitably, :timeout, 100)
    Application.put_env(:inevitably, :interval, 1)
    Process.put(:attempt, 0)

    result =
      eventually do
        attempt = Process.get(:attempt, 0) + 1
        Process.put(:attempt, attempt)

        assert attempt >= 3
        :from_global_config
      end

    assert result == :from_global_config
    assert Process.get(:attempt) == 3
  end

  test "per-call options override global application config" do
    Application.put_env(:inevitably, :timeout, 1)
    Application.put_env(:inevitably, :interval, 1)
    Process.put(:attempt, 0)

    result =
      eventually timeout: 100, interval: 1 do
        attempt = Process.get(:attempt, 0) + 1
        Process.put(:attempt, attempt)

        assert attempt >= 3
        :from_per_call_opts
      end

    assert result == :from_per_call_opts
    assert Process.get(:attempt) == 3
  end

  defp restore_env(key, nil), do: Application.delete_env(:inevitably, key)

  defp restore_env(key, value), do: Application.put_env(:inevitably, key, value)
end
