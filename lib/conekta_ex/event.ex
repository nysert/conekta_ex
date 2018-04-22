defmodule ConektaEx.Event do
  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :object,
    :livemode,
    :created_at,
    :type,
    :data,
    :webhook_status,
    :created_at,
    :webhook_logs
  ]

  @doc ~S"""
  Decodes a valid json binary to ConektaEx.Event

  ## Examples

      iex> decode(valid_json)
      {:ok, %ConektaEx.Event{}}

      iex> decode(invalid_json)
      {:error, invalid_json}

  """
  @spec decode(binary()) :: {:ok, t} | {:error, binary()}
  def decode(bin) when is_binary(bin) do
    case Poison.decode(bin, as: %ConektaEx.Event{}) do
      {:error, _} -> {:error, bin}
      {:ok, s} -> {:ok, s}
    end
  end
end
