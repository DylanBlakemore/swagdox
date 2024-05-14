defmodule Swagdox.User do
  @moduledoc """
  Represents a user.

  [Swagdox] Schema:
    @name User

    @property id, integer, "User id"
    @property name, string, "User name"
    @property email, string, "User email"
    @property orders, [OrderName], "User orders"
  """
  use Ecto.Schema

  alias Swagdox.Order

  embedded_schema do
    field :name, :string
    field :email, :string
    has_many :orders, Order
  end
end
