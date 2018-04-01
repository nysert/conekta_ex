defmodule ConektaEx.Error do
  alias ConektaEx.ErrorDetail

  defstruct [
    :type,
    :log_id,
    :object,
    :details
  ]

  def decode(json) do
    case Poison.decode(json, as: response()) do
      {:ok, error} ->
        {:error, error}

      {:error, _error} ->
        raise "can not decode #{json}"
    end
  end

  def response() do
    %__MODULE__{
      details: [%ErrorDetail{}]
    }
  end
end
