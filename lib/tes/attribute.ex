defmodule Tes.Attribute do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: false}

  schema "attributes" do
    field :name
  end
end
