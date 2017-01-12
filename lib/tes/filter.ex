defmodule Tes.Filter do
  # Dialogue and journal entries rely on sequential records - :dialogue marks the start of a new
  # entry and then all :info entries (until the next :dialogue) belong to that :dialogue
  # Collect them all together here
  def by_type(stream, key) when key in [:journal, :dialogue] do
    stream
    |> Enum.drop_while(fn {type, _record} -> type != key end)
    |> group_dialogues
  end

  def by_type(stream, selected_type) do
    Stream.filter_map(
      stream,
      fn {type, _record} -> type == selected_type end,
      fn {_type, record} -> record end
    )
  end

  def filter_by_condition_value(dialogue, field, value) do
    Enum.any?(Map.get(dialogue, :infos, []), fn(info) ->
      if Map.get(info, :conditions) != nil do
        Enum.any?(Map.get(info, :conditions), fn({condition, _val}) ->
          condition[field] == value
        end)
      else
        false
      end
    end)
  end

  defp group_dialogues([]), do: []
  defp group_dialogues([{key, dialogue} | rest]) when key in [:journal, :dialogue] do
    group_dialogues(rest, dialogue, [])
  end

  defp group_dialogues([{key, dialogue} | rest], current, list) when key in [:journal, :dialogue] do
    group_dialogues(rest, dialogue, [current | list])
  end

  defp group_dialogues([{:info, info} | rest], current, list) do
    current = Map.update!(current, :infos, &([info | &1]))
    group_dialogues(rest, current, list)
  end

  defp group_dialogues(_other, current, list) do
    [current | list]
    |> Enum.reverse
  end
end
