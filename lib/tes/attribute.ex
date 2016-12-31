defmodule Tes.Attribute do
  @attributes %{0 => "Strength", 1 => "Intelligence", 2 => "Willpower", 3 => "Agility",
    4 => "Speed", 5 => "Endurance", 6 => "Personality", 7 => "Luck"}

  def find(id) do
    Map.get(@attributes, id)
  end
end
