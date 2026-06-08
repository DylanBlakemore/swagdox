defmodule Swagdox.Order do
  @moduledoc """
  An order placed by a customer

  [Swagdox] Schema:
    @name OrderName

    @property item, string, "Order item", min_length: 1
    @property number, integer, "Order number", minimum: 1
    @property status, string, "Order status", enum: ["pending", "shipped", "delivered"]

    @example %{
      item: "item",
      number: 1
    }
  """
  use Ecto.Schema

  embedded_schema do
    field :item, :string
    field :number, :integer
    field :user_id, :integer
  end
end
