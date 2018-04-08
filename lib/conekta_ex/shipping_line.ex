defmodule ConektaEx.ShippingLine do
  defstruct [
    :id,
    :amount,
    :tracking_number,
    :carrier,
    :method,
    :metadata
  ]
end
