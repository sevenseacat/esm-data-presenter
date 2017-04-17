defmodule VariableSizes do
  @moduledoc """
  Defines common variable sizes to be used in pattern matching ESM file contents.

  ## Examples

      iex> <<value::long>> = File.read(file, 32)
  """
  defmacro long do
    quote do: signed-little-integer-size(32)
  end

  defmacro lfloat do
    quote do: signed-little-float-size(32)
  end

  defmacro short do
    quote do: signed-little-integer-size(16)
  end

  defmacro byte do
    quote do: signed-little-integer-size(8)
  end
end
