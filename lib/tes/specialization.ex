defmodule Tes.Specialization do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: false}

  schema "specializations" do
    field :name
  end
end
