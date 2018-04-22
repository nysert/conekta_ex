defmodule ConektaEx.Charge do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :created_at,
    :currency,
    :amount,
    :monthly_installments,
    :livemode,
    :payment_method,
    :object,
    :status,
    :fee,
    :order_id
  ]
end
