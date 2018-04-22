defmodule ConektaEx.ErrorDetail do
  @type t :: %__MODULE__{}

  defstruct [
    :code,
    :debug_message,
    :message,
    :param
  ]
end
