defmodule ConektaEx.Plan do
  alias ConektaEx.StructList
  alias ConektaEx.HTTPClient

  @endpoint "/plans"

  defstruct [
    :id,
    :object,
    :livemode,
    :created_at,
    :name,
    :amount,
    :currency,
    :interval,
    :frequency,
    :expiry_count,
    :trial_period_days
  ]

  @doc ~S"""
  Retrieves a list of plans.
  """
  def list() do
    @endpoint
    |> HTTPClient.get()
    |> parse_list_response()
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Plan.
  See 'ConectaEx.StructList.request_next/2' for examples.
  """
  def next_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_next(limit)
    |> parse_list_response()
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Plan.
  See 'ConectaEx.StructList.request_previous/2' for examples.
  """
  def previous_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_previous(limit)
    |> parse_list_response()
  end

  @doc ~S"""
  Retrieves a plan with plan_id

  ## Examples

      iex> retrieve(ok_plan_id)
      {:ok, %ConektaEx.Plan{}}

      iex> retrieve(bad_plan_id)
      {:error, %ConektaEx.Error{}}
  """
  def retrieve(plan_id) do
    "#{@endpoint}/#{plan_id}"
    |> HTTPClient.get()
    |> parse_response()
  end

  @doc ~S"""
  Creates a plan.

  ## Examples

      iex> create(map_with_valid_params)
      {:ok, %ConektaEx.Plan{}}

      iex> create(map_with_bad_params)
      {:error, %ConektaEx.Error{}}
  """
  def create(attrs) when is_map(attrs) do
    body = Poison.encode!(attrs)

    @endpoint
    |> HTTPClient.post(body)
    |> parse_response()
  end

  @doc ~S"""
  Updates a plan with plan_id and Map attrs

  ## Examples

      iex> update(ok_plan_id, ok_attrs)
      {:ok, %ConektaEx.Plan{}}

      iex> update(bad_plan_id, ok_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update(plan_id, attrs)
      when is_binary(plan_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{plan_id}"
    |> HTTPClient.put(body)
    |> parse_response()
  end

  @doc ~S"""
  Deletes a plan with plan_id

  ## Examples

      iex> delete(ok_plan_id)
      {:ok, %ConektaEx.Plan{}}

      iex> delete(bad_plan_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete(plan_id) when is_binary(plan_id) do
    "#{@endpoint}/#{plan_id}"
    |> HTTPClient.delete()
    |> parse_response()
  end

  defp parse_response({:error, res}), do: {:error, res}

  defp parse_response({:ok, res}) do
    {:ok, Poison.decode!(res.body, as: response())}
  end

  defp parse_list_response({:error, res}), do: {:error, res}

  defp parse_list_response({:ok, res}) do
    res_struct = %StructList{data: [response()]}
    {:ok, Poison.decode!(res.body, as: res_struct)}
  end

  defp response(), do: %__MODULE__{}
end
