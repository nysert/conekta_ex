defmodule ConektaEx.TaxLine do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :description,
    :amount,
    :metadata
  ]
end
