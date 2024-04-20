defmodule Swagdox.User do
  @moduledoc """
  Represents a user.

  [Swagdox] Schema:
    @name User

    @property id, integer, "User id"
    @property name, string, "User name"
    @property email, string, "User email"
  """
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :email, :string
  end
end
