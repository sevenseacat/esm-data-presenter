defmodule Tes.Birthsign do
  @moduledoc """
  Represents the astrological birthsign a player chooses upon starting a new character.

  A birthsign grants the player one or more abilities/curses (constant effect), spells (cast when
  used), or powers (to be used once per day).
  """

  defstruct [:key, :name, :description, :skills]
end
