defmodule SwagdoxWeb.OrderController do
  use Swagdox.Controller, schemas: [Swagdox.Order]

  @doc """
  Returns an Order.

  [Swagdox] API:
    @param id(path), integer, "Order ID", required: true

    @response 200, Order, "Order found"
    @response 403, "Order not authorized"
    @response 404, "Order not found"
  """
  @spec show(any(), map()) :: nil
  def show(_conn, _params) do
  end

  @doc """
  Returns a list of Orders

  [Swagdox] API:
    @response 200, [Order], "Orders found"
    @response 403, "Orders not authorized"
  """
  @spec index(any(), map()) :: nil
  def index(_conn, _params) do
  end

  @doc """
  Creates an Order.

  [Swagdox] API:
    @param order(body), object, "Order attributes", required: true

    @response 201, Order, "Order created"
    @response 400, "Invalid order attributes"
  """
  @spec create(any(), map()) :: nil
  def create(_conn, _params) do
  end

  @doc """
  Deletes an Order.

  [Swagdox] API:
    @param id(path), integer, "Order ID", required: true

    @response 204, "Order deleted"
    @response 403, "Order not authorized"
    @response 404, "Order not found"
  """
  @spec delete(any(), map()) :: nil
  def delete(_conn, _params) do
  end
end
