defmodule TesTest do
  use ExUnit.Case

  # TODO: Revise these tests with a real CS-generated ESM. At the moment it's a MWedit-generated one.
  setup do
    {:ok, stream: Tes.EsmFile.stream("test/fixtures/Test.esm")}
  end

  test "can read Books successfully", %{stream: stream} do
    books = Tes.Filter.by_type(stream, :book)

    assert length(books) == 1
    assert List.first(books) == %{id: "my_book", name: "My Awesome Book",
      enchantment_points: 10, weight: 2.5, value: 100, model: "", scroll: false,
      text: "This book is pretty awesome.", skill_id: 6, enchantment_name: nil,
      script_name: nil, texture: nil}
  end

  test "can read Factions successfully", %{stream: stream} do
    factions = Tes.Filter.by_type(stream, :faction)

    assert length(factions) == 1
    assert List.first(factions) == %{key: "awesome",
      name: "Awesome", favorite_attribute_ids: [3, 7],
      favorite_skill_ids: [9, 18, 19, 4, 17], reactions: [{"awesome", 1}],
      hidden: true, ranks: [
        %{name: "Rank A", attribute_1: 10, attribute_2: 10, skill_1: 20, skill_2: 15, faction: 0},
        %{name: "Rank B", attribute_1: 15, attribute_2: 12, skill_1: 20, skill_2: 20, faction: 10},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0},
        %{name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, faction: 0}
      ]
    }
  end
end
