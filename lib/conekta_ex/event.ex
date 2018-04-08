defmodule ConektaEx.Event do
  defstruct [
    :id,
    :object,
    :livemode,
    :created_at,
    :type,
    :data
  ]
end
