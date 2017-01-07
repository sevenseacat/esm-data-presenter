defmodule Tes.Filter do
  def by_type(stream, selected_type) do
    Enum.filter_map(
      stream,
      fn {type, _record} -> type == selected_type end,
      fn {_type, record} -> record end
    )
  end
end
