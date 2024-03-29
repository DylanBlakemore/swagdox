defmodule Swagdox.User do
  use Ecto.Schema
  use Swagdox.Schema

  embedded_schema do
    field :name, :string
    field :email, :string
  end
end
