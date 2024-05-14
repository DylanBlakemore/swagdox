defmodule Swagdox.Controller do
  @moduledoc """
  The Controller module is used to define controller-level
  properties in an OpenAPI specification.
  """

  @spec __using__(keyword()) :: Macro.t()
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @spec __security__() :: map()
      def __security__ do
        %{
          type: unquote(opts)[:auth],
          token: unquote(opts)[:token]
        }
      end
    end
  end
end
