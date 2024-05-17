defmodule SwagdoxWeb.UserController do
  @doc """
  Returns a User.

  [Swagdox] API:
    @param id(path), integer, "User ID", required: true

    @response 200, User, "User found"
    @response 403, "User not authorized"
    @response 404, "User not found"

    @security BasicAuth, [read]
  """
  @spec show(any(), map()) :: nil
  def show(_conn, _params) do
  end

  @doc """
  Returns a list of Users
  """
  @spec index(any(), map()) :: nil
  def index(_conn, _params) do
  end

  @doc """
  Creates a User.

  [Swagdox] API:
    @param user(body), object, "User attributes", required: true

    @response 201, User, "User created"
    @response 400, "Invalid user attributes"

    @security BasicAuth, [admin]
  """
  @spec create(any(), map()) :: nil
  def create(_conn, _params) do
  end

  @spec delete(any(), map()) :: nil
  def delete(_conn, _params) do
  end
end
