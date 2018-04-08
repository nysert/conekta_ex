defmodule ConektaEx.Order do
  alias ConektaEx.StructList
  alias ConektaEx.LineItem
  alias ConektaEx.ShippingLine
  alias ConektaEx.TaxLine
  alias ConektaEx.DiscountLine
  alias ConektaEx.ShippingContact
  alias ConektaEx.Address
  alias ConektaEx.Customer
  alias ConektaEx.Charge
  alias ConektaEx.PaymentSource
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
    |> parse_response(:order_list)
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Order.
  See 'ConectaEx.StructList.request_next/2' for examples.
  """
  def next_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_next(limit)
    |> parse_response(:order_list)
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Order.
  See 'ConectaEx.StructList.request_previous/2' for examples.
  """
  def previous_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_previous(limit)
    |> parse_response(:order_list)
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

    "#{@endpoint}/#{order_id}/charges"
    |> HTTPClient.put(body)
    |> parse_response()
  end

  @doc ~S"""
  Captures an order with order_id

  ## Examples

      iex> capture(ok_order_id)
      {:ok, %ConektaEx.Order{}}

      iex> capture(bad_order_id)
      {:error, %ConektaEx.Error{}}
  """
  def capture(order_id) when is_binary(order_id) do
    "#{@endpoint}/#{order_id}/capture"
    |> HTTPClient.post("")
    |> parse_response()
  end

  @doc ~S"""
  Refunds an order with order_id, adding reason and
  amount if provided

  ## Examples

      iex> refund(ok_order_id, "ugh")
      {:ok, %ConektaEx.Order{}}

      iex> refund(bad_order_id, "ugh")
      {:error, %ConektaEx.Error{}}
  """
  def refund(order_id, reason, amount \\ nil)
      when is_binary(order_id) do
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

  @doc ~S"""
  Creates a charge for an order with order_id

  ## Examples

      iex> refund(order_id, ok_attrs)
      {:ok, %ConektaEx.Order{}}

      iex> refund(order_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def create_charge(order_id, attrs)
      when is_binary(order_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/refunds"
    |> HTTPClient.post(body)
    |> parse_response()
  end

  @doc ~S"""
  Creates a line item for an order with order_id

  ## Examples

      iex> create_line_item(order_id, ok_attrs)
      {:ok, %ConektaEx.LineItem{}}

      iex> create_line_item(order_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def create_line_item(order_id, attrs)
      when is_binary(order_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/line_items"
    |> HTTPClient.post(body)
    |> parse_response(:line_item)
  end

  @doc ~S"""
  Updates a line item for an order with order_id and line_id

  ## Examples

      iex> update_line_item(order_id, line_id, ok_attrs)
      {:ok, %ConektaEx.LineItem{}}

      iex> update_line_item(order_id, line_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update_line_item(order_id, line_id, attrs)
      when is_binary(order_id) and is_binary(line_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/line_items/#{line_id}"
    |> HTTPClient.put(body)
    |> parse_response(:line_item)
  end

  @doc ~S"""
  Deletes a line item for an order with order_id and line_id

  ## Examples

      iex> delete_line_item(order_id, line_id)
      {:ok, %ConektaEx.LineItem{}}

      iex> delete_line_item(order_id, bad_line_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete_line_item(order_id, line_id)
      when is_binary(order_id) and is_binary(line_id) do
    "#{@endpoint}/#{order_id}/line_items/#{line_id}"
    |> HTTPClient.delete()
    |> parse_response(:line_item)
  end

  @doc ~S"""
  Creates a shipping line for an order with order_id

  ## Examples

      iex> create_shipping_line(order_id, ok_attrs)
      {:ok, %ConektaEx.ShippingLine{}}

      iex> create_shipping_line(order_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def create_shipping_line(order_id, attrs)
      when is_binary(order_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/shipping_lines"
    |> HTTPClient.post(body)
    |> parse_response(:shipping_line)
  end

  @doc ~S"""
  Updates a shipping line for an order with order_id and line_id

  ## Examples

      iex> update_shipping_line(order_id, line_id, ok_attrs)
      {:ok, %ConektaEx.ShippingLine{}}

      iex> update_shipping_line(order_id, line_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update_shipping_line(order_id, line_id, attrs)
      when is_binary(order_id) and is_binary(line_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/shipping_lines/#{line_id}"
    |> HTTPClient.put(body)
    |> parse_response(:shipping_line)
  end

  @doc ~S"""
  Deletes a shipping line for an order with order_id and line_id

  ## Examples

      iex> delete_shipping_line(order_id, line_id)
      {:ok, %ConektaEx.ShippingLine{}}

      iex> delete_shipping_line(order_id, bad_line_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete_shipping_line(order_id, line_id)
      when is_binary(order_id) and is_binary(line_id) do
    "#{@endpoint}/#{order_id}/shipping_lines/#{line_id}"
    |> HTTPClient.delete()
    |> parse_response(:shipping_line)
  end

  @doc ~S"""
  Creates a discount line for an order with order_id

  ## Examples

      iex> create_discount_line(order_id, ok_attrs)
      {:ok, %ConektaEx.DiscountLine{}}

      iex> create_discount_line(order_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def create_discount_line(order_id, attrs)
      when is_binary(order_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/discount_lines"
    |> HTTPClient.post(body)
    |> parse_response(:discount_line)
  end

  @doc ~S"""
  Updates a discount line for an order with order_id and line_id

  ## Examples

      iex> update_discount_line(order_id, line_id, ok_attrs)
      {:ok, %ConektaEx.DiscountLine{}}

      iex> update_discount_line(order_id, line_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update_discount_line(order_id, line_id, attrs)
      when is_binary(order_id) and is_binary(line_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/discount_lines/#{line_id}"
    |> HTTPClient.put(body)
    |> parse_response(:discount_line)
  end

  @doc ~S"""
  Deletes a discount line for an order with order_id and line_id

  ## Examples

      iex> delete_discount_line(order_id, line_id)
      {:ok, %ConektaEx.DiscountLine{}}

      iex> delete_discount_line(order_id, bad_line_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete_discount_line(order_id, line_id)
      when is_binary(order_id) and is_binary(line_id) do
    "#{@endpoint}/#{order_id}/discount_lines/#{line_id}"
    |> HTTPClient.delete()
    |> parse_response(:discount_line)
  end

  @doc ~S"""
  Creates a tax line for an order with order_id

  ## Examples

      iex> create_tax_line(order_id, ok_attrs)
      {:ok, %ConektaEx.TaxLine{}}

      iex> create_tax_line(order_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def create_tax_line(order_id, attrs)
      when is_binary(order_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/tax_lines"
    |> HTTPClient.post(body)
    |> parse_response(:tax_line)
  end

  @doc ~S"""
  Updates a tax line for an order with order_id and line_id

  ## Examples

      iex> update_tax_line(order_id, line_id, ok_attrs)
      {:ok, %ConektaEx.TaxLine{}}

      iex> update_tax_line(order_id, line_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update_tax_line(order_id, line_id, attrs)
      when is_binary(order_id) and is_binary(line_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{order_id}/tax_lines/#{line_id}"
    |> HTTPClient.put(body)
    |> parse_response(:tax_line)
  end

  @doc ~S"""
  Deletes a tax line for an order with order_id and line_id

  ## Examples

      iex> delete_tax_line(order_id, line_id)
      {:ok, %ConektaEx.TaxLine{}}

      iex> delete_tax_line(order_id, bad_line_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete_tax_line(order_id, line_id)
      when is_binary(order_id) and is_binary(line_id) do
    "#{@endpoint}/#{order_id}/tax_lines/#{line_id}"
    |> HTTPClient.delete()
    |> parse_response(:tax_line)
  end

  defp parse_response({:error, res}) do
    {:error, res}
  end

  defp parse_response({:ok, res}) do
    {:ok, Poison.decode!(res.body, as: response())}
  end

  defp parse_response({:error, res}, _) do
    {:error, res}
  end

  defp parse_response({:ok, res}, :order_list) do
    struct = %StructList{data: [response()]}
    {:ok, Poison.decode!(res.body, as: struct)}
  end

  defp parse_response({:ok, res}, :line_item) do
    {:ok, Poison.decode!(res.body, as: %LineItem{})}
  end

  defp parse_response({:ok, res}, :shipping_line) do
    {:ok, Poison.decode!(res.body, as: %ShippingLine{})}
  end

  defp parse_response({:ok, res}, :discount_line) do
    {:ok, Poison.decode!(res.body, as: %DiscountLine{})}
  end

  defp parse_response({:ok, res}, :tax_line) do
    {:ok, Poison.decode!(res.body, as: %TaxLine{})}
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
      customer_info: %Customer{},
      charges: %StructList{
        data: [
          %Charge{payment_method: %PaymentSource{}}
        ]
      }
    }
  end
end
