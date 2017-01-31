defmodule VariableSizes do
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
