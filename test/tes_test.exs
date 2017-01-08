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
    assert List.first(factions) == %{id: "awesome", name: "Awesome",
      favorite_skill_ids: [9, 18, 19, 4, 17], reactions: [%{target_id: "awesome", adjustment: 1}],
      hidden: true, attribute_1_id: 3, attribute_2_id: 7, ranks: [
        %{number: 1, name: "Rank A", attribute_1: 10, attribute_2: 10, skill_1: 20, skill_2: 15, reputation: 0},
        %{number: 2, name: "Rank B", attribute_1: 15, attribute_2: 12, skill_1: 20, skill_2: 20, reputation: 10},
        %{number: 3, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0},
        %{number: 4, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0},
        %{number: 5, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0},
        %{number: 6, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0},
        %{number: 7, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0},
        %{number: 8, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0},
        %{number: 9, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0},
        %{number: 10, name: "", attribute_1: 0, attribute_2: 0, skill_1: 0, skill_2: 0, reputation: 0}
      ]
    }
  end
end
