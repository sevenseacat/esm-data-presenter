defmodule Tes.Specialization do
  @specializations %{0 => "Combat", 1 => "Magic", 2 => "Stealth"}

  def find(id) do
    Map.get(@specializations, id)
  end
end
