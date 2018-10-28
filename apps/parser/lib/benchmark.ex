defmodule Benchmark do
  @moduledoc """
  Quick and dirty benchmarking of a function, in seconds.

  Source: http://stackoverflow.com/a/29674651/560215
  """

  @spec measure(func :: fun()) :: {String.t(), any}
  def measure(func) do
    {time, result} = :timer.tc(func)
    {"#{time / 1_000_000}sec", result}
  end
end
