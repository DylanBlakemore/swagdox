defmodule Swagdox.Parameter do
  defstruct [
    :name,
    :in,
    :required,
    :description,
    :schema
  ]
end
