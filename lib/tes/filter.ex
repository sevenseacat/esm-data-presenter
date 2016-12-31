defmodule Tes.Filter do
  def books(stream), do: filter_type(stream, Tes.Book)
  def skills(stream), do: filter_type(stream, Tes.Skill)

  defp filter_type(stream, type) do
    Enum.filter(stream, &(Map.get(&1, :__struct__) == type))
  end
end