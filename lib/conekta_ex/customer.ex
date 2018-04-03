defmodule ConektaEx.Customer do
  alias ConektaEx.ShippingContact
  alias ConektaEx.Subscription
  alias ConektaEx.PaymentSource
  alias ConektaEx.StructList
  alias ConektaEx.Address
  alias ConektaEx.HTTPClient

  @endpoint "/customers"

  defstruct [
    :id,
    :name,
    :phone,
    :email,
    :plan_id,
    :payment_sources,
    :corporate,
    :shipping_contacts,
    :subscriptions,
    :object,
    :livemode,
    :default_shipping_contact_id,
    :default_payment_source_id
  ]

  @doc ~S"""
  Retrieves a list of customers.
  """
  def list() do
    @endpoint
    |> HTTPClient.get()
    |> parse_response(:customer_list)
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Customer.
  See 'ConectaEx.StructList.request_next/2' for examples.
  """
  def next_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_next(limit)
    |> parse_response(:customer_list)
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Customer.
  See 'ConectaEx.StructList.request_previous/2' for examples.
  """
  def previous_page(struct_list, limit \\ nil) do
    struct_list
    |> StructList.request_previous(limit)
    |> parse_response(:customer_list)
  end

  @doc ~S"""
  Retrieves a customer with customer_id

  ## Examples

      iex> retrieve(ok_customer_id)
      {:ok, %ConektaEx.Customer{}}

      iex> retrieve(bad_customer_id)
      {:error, %ConektaEx.Error{}}
  """
  def retrieve(customer_id) do
    "#{@endpoint}/#{customer_id}"
    |> HTTPClient.get()
    |> parse_response()
  end

  @doc ~S"""
  Creates a customer.

  ## Examples

      iex> create(%{name: ok_name, email: ok_email})
      {:ok, %ConektaEx.Customer{}}

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
  Updates a customer with customer_id and Map attrs

  ## Examples

      iex> update(ok_customer_id, ok_attrs)
      {:ok, %ConektaEx.Customer{}}

      iex> update(bad_customer_id, ok_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update(customer_id, attrs)
      when is_binary(customer_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{customer_id}"
    |> HTTPClient.put(body)
    |> parse_response()
  end

  @doc ~S"""
  Deletes a customer with customer_id

  ## Examples

      iex> delete(ok_customer_id)
      {:ok, %ConektaEx.Customer{}}

      iex> delete(bad_customer_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete(customer_id) when is_binary(customer_id) do
    "#{@endpoint}/#{customer_id}"
    |> HTTPClient.delete()
    |> parse_response()
  end

  @doc ~S"""
  Creates a payment source for a customer with a customer_id.

  ## Examples

      iex> create_payment_source(customer_id, "card", ok_token)
      {:ok, %ConektaEx.Customer{}}

      iex> create_payment_source(customer_id, "card", bad_token)
      {:error, %ConektaEx.Error{}}
  """
  def create_payment_source(customer_id, type, token_id)
      when is_binary(customer_id) do
    body = Poison.encode!(%{type: type, token_id: token_id})

    "#{@endpoint}/#{customer_id}/payment_sources/"
    |> HTTPClient.post(body)
    |> parse_response(:payment_source)
  end

  @doc ~S"""
  Updates a payment source for a customer with a customer_id.

  ## Examples

      iex> update_payment_source(customer_id, ok_attrs)
      {:ok, %ConektaEx.Customer{}}

      iex> update_payment_source(customer_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update_payment_source(customer_id, source_id, attrs)
      when is_binary(customer_id) and is_binary(source_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{customer_id}/payment_sources/#{source_id}"
    |> HTTPClient.put(body)
    |> parse_response(:payment_source)
  end

  @doc ~S"""
  Deletes a payment source for a customer with a customer_id.

  ## Examples

      iex> delete(customer_id, ok_source_id)
      {:ok, %ConektaEx.Customer{}}

      iex> delete(customer_id, bad_source_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete_payment_source(customer_id, source_id)
      when is_binary(customer_id) and is_binary(source_id) do
    "#{@endpoint}/#{customer_id}/payment_sources/#{source_id}"
    |> HTTPClient.delete()
    |> parse_response(:payment_source)
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

  defp parse_response({:ok, res}, :customer_list) do
    struct = %StructList{data: [response()]}
    {:ok, Poison.decode!(res.body, as: struct)}
  end

  defp parse_response({:ok, res}, :payment_source) do
    {:ok, Poison.decode!(res.body, as: %PaymentSource{})}
  end

  defp response() do
    %__MODULE__{
      payment_sources: %StructList{
        data: [%PaymentSource{address: %Address{}}]
      },
      shipping_contacts: %StructList{
        data: [%ShippingContact{address: %Address{}}]
      },
      subscriptions: %StructList{
        data: [%Subscription{}]
      }
    }
  end
end
