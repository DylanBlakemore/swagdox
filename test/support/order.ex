defmodule Swagdox.Order do
  @moduledoc """
  Represents an order.

  [Swagdox] Schema:
    @name OrderName

    @property item, string, "Order item"
    @property number, integer, "Order number"
  """
  use Ecto.Schema

  embedded_schema do
    field :item, :string
    field :number, :integer
    field :user_id, :integer
  end
end
