defmodule Swagdox.SearchResult do
  @moduledoc """
  A single search result

  [Swagdox] Schema:
    @name SearchResult
    @type User | OrderName
    @discriminator kind, %{user: User, order: OrderName}
  """
end
