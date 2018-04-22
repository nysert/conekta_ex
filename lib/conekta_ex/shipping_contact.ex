defmodule ConektaEx.ShippingContact do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :phone,
    :receiver,
    :between_streets,
    :address
  ]
end
