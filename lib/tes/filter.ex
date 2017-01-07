defmodule Tes.Filter do
  def by_type(stream, selected_type) do
    Enum.filter_map(
      stream,
      fn {type, record} -> type == selected_type end,
      fn {type, record} -> record end
    )
  end
end
