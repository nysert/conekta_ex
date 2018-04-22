defmodule ConektaEx.Subscription do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :object,
    :created_at,
    :canceled_at,
    :paused_at,
    :billing_cycle_start,
    :billing_cycle_end,
    :trial_start,
    :trial_end,
    :plan_id,
    :status,
    :card_id
  ]
end
