defmodule ConektaEx.LineItem do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :name,
    :description,
    :unit_price,
    :quantity,
    :sku,
    :tags,
    :brand,
    :metadata
  ]
end
