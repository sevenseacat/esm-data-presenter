defmodule VariableSizes do
  @moduledoc """
  Defines common variable sizes to be used in pattern matching ESM file contents.

  ## Examples

      iex> <<value::long>> = File.read(file, 32)
  """

  # Disable one check until this issue is fixed.
  # https://github.com/rrrene/credo/issues/144
  @lint {Credo.Check.Consistency.SpaceAroundOperators, false}
  defmacro long do
    quote do: signed-little-integer-size(32)
  end

  @lint {Credo.Check.Consistency.SpaceAroundOperators, false}
  defmacro lfloat do
    quote do: signed-little-float-size(32)
  end

  @lint {Credo.Check.Consistency.SpaceAroundOperators, false}
  defmacro short do
    quote do: signed-little-integer-size(16)
  end

  @lint {Credo.Check.Consistency.SpaceAroundOperators, false}
  defmacro byte do
    quote do: signed-little-integer-size(8)
  end
end
