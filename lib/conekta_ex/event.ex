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

      iex> decode(valid_bin)
      {:ok, %ConektaEx.Event{}}

      iex> decode(invalid_bin)
      {:error, invalid_json}

      iex> decode(valid_map)
      {:ok, %ConektaEx.Event{}}

      iex> decode(invalid_map)
      {:error, invalid_map}

  """
  @spec decode(binary() | %{required(binary()) => any()}) :: {:ok, t} | {:error, binary() | map()}
  def decode(bin) when is_binary(bin) do
    case Poison.decode(bin, as: %ConektaEx.Event{}) do
      {:error, _} -> {:error, bin}
      {:ok, s} -> {:ok, s}
    end
  end

  def decode(attr) when is_map(attr) do
    case to_struct(__MODULE__, attr) do
      %{id: id} when is_nil(id) ->
        {:error, attr}

      %{id: id} = event when is_binary(id) ->
        {:ok, event}
    end
  end

  defp to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
