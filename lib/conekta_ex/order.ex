defmodule ConektaEx.Order do
  alias ConektaEx.StructList
  alias ConektaEx.LineItem
  alias ConektaEx.ShippingLine
  alias ConektaEx.TaxLine
  alias ConektaEx.DiscountLine
  alias ConektaEx.ShippingContact
  alias ConektaEx.Address
  alias ConektaEx.Customer
  alias ConektaEx.HTTPClient

  @endpoint "/orders"

  defstruct [
    :id,
    :object,
    :created_at,
    :updated_at,
    :currency,
    :line_items,
    :shipping_lines,
    :tax_lines,
    :discount_lines,
    :livemode,
    :metadata,
    :shipping_contact,
    :amount,
    :amount_refunded,
    :payment_status,
    :customer_info,
    :charges
  ]

  @doc ~S"""
  Retrieves a list of orders.
  """
  def list() do
    @endpoint
    |> HTTPClient.get()
    |> parse_list_response()
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Order.
  See 'ConectaEx.StructList.request_next/2' for examples.
  """
  def next_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_next(limit)
    |> parse_list_response()
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Order.
  See 'ConectaEx.StructList.request_previous/2' for examples.
  """
  def previous_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_previous(limit)
    |> parse_list_response()
  end

  @doc ~S"""
  Retrieves an order with order_id

  ## Examples

      iex> retrieve(ok_order_id)
      {:ok, %ConektaEx.Order{}}

      iex> retrieve(bad_order_id)
      {:error, %ConektaEx.Error{}}
  """
  def retrieve(order_id) do
    "#{@endpoint}/#{order_id}"
    |> HTTPClient.get()
    |> parse_response()
  end

  @doc ~S"""
  Creates an order.

  ## Examples

      iex> create(%{name: ok_name, email: ok_email})
      {:ok, %ConektaEx.Order{}}

      iex> create(%{email: bad_email})
      {:error, %ConektaEx.Error{}}
  """
  def create(attrs) when is_map(attrs) do
    body = Poison.encode!(attrs)

    @endpoint
    |> HTTPClient.post(body)
    |> parse_response()
  end

  @doc ~S"""
  Updates an order with order_id and Map attrs

  ## Examples

      iex> update(ok_order_id, ok_attrs)
      {:ok, %ConektaEx.Order{}}

      iex> update(bad_order_id, ok_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update(order_id, attrs)
      when is_binary(order_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}"
    |> HTTPClient.put(body)
    |> parse_response()
  end

  @doc ~S"""
  Refounds an order with order_id and adding
  reason and amount if provided

  ## Examples

      iex> refund(ok_order_id, "ugh")
      {:ok, %ConektaEx.Order{}}

      iex> refund(bad_order_id, "ugh")
      {:error, %ConektaEx.Error{}}
  """
  def refund(order_id, reason, amount \\ nil)
      when is_binary order_id do
    body =
      amount
      |> case do
        nil -> %{}
        _ -> Map.put(%{}, :amount, amount)
      end
      |> Map.put(:reason, reason)
      |> Poison.encode!()

    "#{@endpoint}/#{order_id}/refunds"
    |> HTTPClient.post(body)
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

  defp response() do
    %__MODULE__{
      line_items: %StructList{
        data: [%LineItem{}]
      },
      shipping_lines: %StructList{
        data: [%ShippingLine{}]
      },
      tax_lines: %StructList{
        data: [%TaxLine{}]
      },
      discount_lines: %StructList{
        data: [%DiscountLine{}]
      },
      shipping_contact: %ShippingContact{
        address: %Address{}
      },
      customer_info: %Customer{}
    }
  end
end
