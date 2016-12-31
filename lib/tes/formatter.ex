defmodule Tes.EsmFormatter do
  # Hardcoded things - there's a few of them
  @skill_names %{0 => "Block", 1 => "Armorer", 2 => "Medium Armor", 3 => "Heavy Armor",
    4 => "Blunt Weapon", 5 => "Long Blade", 6 => "Axe", 7 => "Spear", 8 => "Athletics",
    9 => "Enchant", 10 => "Destruction", 11 => "Alteration", 12 => "Illusion",
    13 => "Conjuration", 14 => "Mysticism", 15 => "Restoration", 16 => "Alchemy",
    17 => "Unarmored", 18 => "Security", 19 => "Sneak", 20 => "Acrobatics",
    21 => "Light Armor", 22 => "Short Blade", 23 => "Marksman", 24 => "Mercantile",
    25 => "Speechcraft", 26 => "Hand to Hand"}

  def skill(%{"INDX" => id, "SKDT" => skdt, "DESC" => desc}) do
    %Tes.Skill{
      id: id,
      name: Map.get(@skill_names, id),
      attribute_id: Map.get(skdt, :attribute_id),
      specialization_id: Map.get(skdt, :specialization_id),
      description: desc
    }
  end

  def book(%{"NAME" => id, "MODL" => model, "FNAM" => name, "BKDT" => bkdt}=raw_data) do
    %Tes.Book{
      id: id,
      name: name,
      model: model,
      weight: Map.get(bkdt, :weight),
      value: Map.get(bkdt, :value),
      scroll: Map.get(bkdt, :scroll),
      skill_id: Map.get(bkdt, :skill_id),
      enchantment_name: Map.get(raw_data, "ENAM"),
      enchantment_points: Map.get(bkdt, :enchantment),
      script_name: Map.get(raw_data, "SCRI"),
      texture: Map.get(raw_data, "ITEX"),
      text: Map.get(raw_data, "TEXT")
    }
  end
end
