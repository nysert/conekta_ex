defmodule ConektaEx.Charge do
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
