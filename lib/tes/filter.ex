defmodule Tes.Filter do
  # Dialogue and journal entries rely on sequential records - :dialogue marks the start of a new
  # entry and then all :info entries (until the next :dialogue) belong to that :dialogue
  # Collect them all together here
  def by_type(stream, key) when key in [:journal, :dialogue] do
    stream
    |> Stream.drop_while(fn {type, _record} -> type != key end)
    |> Stream.take_while(fn {type, _record} -> type in [key, :info] end)
    |> chunk_dialogues(key)
    |> Stream.map(&combine_dialogue_with_infos/1)
    |> Stream.reject(&(&1[:id] == ""))
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

  # Group each dialogue together with its following info blocks (if any).
  # Adapted from http://stackoverflow.com/a/41723947/560215
  defp chunk_dialogues(stream, key) do
    stream
    |> Stream.concat([nil])
    |> Stream.transform([], fn e, acc ->
      case e do
        nil -> {[acc], nil}
        {^key, _} -> {(if Enum.empty?(acc), do: [], else: [acc]), [e]}
        {:info, _} -> {[], acc ++ [e]}
      end
    end)
  end

  defp combine_dialogue_with_infos([{_key, dialogue} | infos]) do
    Map.put(dialogue, :infos, Keyword.values(infos))
  end
end
