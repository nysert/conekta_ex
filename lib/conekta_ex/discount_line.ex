defmodule ConektaEx.DiscountLine do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :code,
    :type,
    :amount
  ]
end
