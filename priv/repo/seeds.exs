# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tes.Repo.insert!(%Tes.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Tes.Repo.delete_all(Tes.Specialization)
Tes.Repo.delete_all(Tes.Attribute)

Enum.each(%{0 => "Combat", 1 => "Magic", 2 => "Stealth"}, fn {id, name} ->
  Tes.Repo.insert!(%Tes.Specialization{id: id, name: name})
end)

Enum.each(%{0 => "Strength", 1 => "Intelligence", 2 => "Willpower", 3 => "Agility",
  4 => "Speed", 5 => "Endurance", 6 => "Personality", 7 => "Luck"}, fn {id, name} ->
  Tes.Repo.insert!(%Tes.Attribute{id: id, name: name})
end)
