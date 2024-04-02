defmodule Swagdox.Order do
  use Ecto.Schema
  use Swagdox.Schema

  embedded_schema do
    field :item, :string
    field :number, :integer
  end
end
