defmodule ConektaEx.LineItem do
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
