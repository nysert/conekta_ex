defmodule ConektaEx.ShippingLine do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :amount,
    :tracking_number,
    :carrier,
    :method,
    :metadata
  ]
end
