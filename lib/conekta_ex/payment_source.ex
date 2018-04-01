defmodule ConektaEx.PaymentSource do
  defstruct [
    :id,
    :object,
    :type,
    :created_at,
    :last4,
    :name,
    :exp_month,
    :exp_year,
    :brand,
    :parent_id,
    :address
  ]
end
