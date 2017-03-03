# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Codex.Repo.insert!(%Codex.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Codex.Repo.delete_all(Codex.Specialization)
Codex.Repo.delete_all(Codex.Attribute)

Enum.each(%{0 => "Combat", 1 => "Magic", 2 => "Stealth"}, fn {id, name} ->
  Codex.Repo.insert!(%Codex.Specialization{id: id, name: name})
end)

Enum.each(%{0 => "Strength", 1 => "Intelligence", 2 => "Willpower", 3 => "Agility",
  4 => "Speed", 5 => "Endurance", 6 => "Personality", 7 => "Luck"}, fn {id, name} ->
  Codex.Repo.insert!(%Codex.Attribute{id: id, name: name})
end)
