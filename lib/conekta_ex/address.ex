defmodule ConektaEx.Address do
  @type t :: %__MODULE__{}

  defstruct [
    :street1,
    :street2,
    :city,
    :state,
    :country,
    :postal_code,
    :residential,
    :object
  ]
end
