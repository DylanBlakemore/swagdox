defmodule SwagdoxWeb.OrderController do
  @doc """
  Returns an Order.

  [Swagdox] API:
    @param id(path), integer, "Order ID", required: true

    @response 200, OrderName, "Order found"
    @response 403, "Order not authorized"
    @response 404, "Order not found"

    @security ApiKey, [read]

    @tags orders
  """
  @spec show(any(), map()) :: nil
  def show(_conn, _params) do
  end

  @doc """
  Returns a list of Orders

  [Swagdox] API:
    @response 200, [OrderName], "Orders found"
    @response 403, "Orders not authorized"

    @security ApiKey, [read]
  """
  @spec index(any(), map()) :: nil
  def index(_conn, _params) do
  end

  @doc """
  Creates an Order.

  [Swagdox] API:
    @param order(body), OrderName, "Order attributes", required: true
    @param organisation(header), string, "The organisation UUID", required: true

    @response 201, OrderName, "Order created"
    @response 400, "Invalid order attributes"

    @security ApiKey, [write]
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

    @security ApiKey, [write]
  """
  @spec delete(any(), map()) :: nil
  def delete(_conn, _params) do
  end
end
