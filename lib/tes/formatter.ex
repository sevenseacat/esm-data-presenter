defmodule Tes.Formatter do
  # Hardcoded things - there's a few of them
  @attributes %{0 => "Strength", 1 => "Intelligence", 2 => "Willpower", 3 => "Agility",
    4 => "Speed", 5 => "Endurance", 6 => "Personality", 7 => "Luck"}
  @specialization %{0 => "Combat", 1 => "Magic", 2 => "Stealth"}
  @skills %{0 => "Block", 1 => "Armorer", 2 => "Medium Armor", 3 => "Heavy Armor",
    4 => "Blunt Weapon", 5 => "Long Blade", 6 => "Axe", 7 => "Spear", 8 => "Athletics",
    9 => "Enchant", 10 => "Destruction", 11 => "Alteration", 12 => "Illusion",
    13 => "Conjuration", 14 => "Mysticism", 15 => "Restoration", 16 => "Alchemy",
    17 => "Unarmored", 18 => "Security", 19 => "Sneak", 20 => "Acrobatics",
    21 => "Light Armor", 22 => "Short Blade", 23 => "Marksman", 24 => "Mercantile",
    25 => "Speechcraft", 26 => "Hand to Hand"}

  def skills(stream) do
    stream
    |> by_key("SKIL")
    |> Stream.map(fn [{"INDX", id}, {"SKDT", skdt}, {"DESC", desc}] ->
      %{
        id: id,
        name: Map.get(@skills, id),
        attribute: Map.get(@attributes, Map.get(skdt, :attribute_id)),
        specialization: Map.get(@specialization, Map.get(skdt, :specialization)),
        description: desc
      }
    end)
  end

  def books(stream) do
    stream
    |> by_key("BOOK")
    |> Stream.map(&book_data/1)
  end

  defp by_key(stream, key) do
    stream
    |> Stream.filter_map(fn {k, _v} -> k == key end, fn {_k, v} -> v end)
  end

  defp book_data(proplist), do: book_data(proplist, %{})

  defp book_data([], book), do: book
  defp book_data([{"NAME", val} | rest], book) do
    book_data(rest, Map.put(book, :id, val))
  end
  defp book_data([{"MODL", val} | rest], book) do
    book_data(rest, Map.put(book, :model, val))
  end
  defp book_data([{"FNAM", val} | rest], book) do
    book_data(rest, Map.put(book, :name, val))
  end
  defp book_data([{"SCRI", val} | rest], book) do
    book_data(rest, Map.put(book, :script_name, val))
  end
  defp book_data([{"ENAM", val} | rest], book) do
    book_data(rest, Map.put(book, :enchantment_name, val))
  end
  defp book_data([{"ITEX", val} | rest], book) do
    book_data(rest, Map.put(book, :texture, val))
  end
  defp book_data([{"TEXT", val} | rest], book) do
    book_data(rest, Map.put(book, :text, val))
  end
  defp book_data([{"BKDT", val} | rest], book) do
    book_data(rest, Map.merge(book, val))
  end
end
