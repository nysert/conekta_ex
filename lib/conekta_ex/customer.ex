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
    :subscription,
    :object,
    :livemode,
    :default_shipping_contact_id,
    :default_payment_source_id
  ]

  @doc ~S"""
  Retrieves a list of customers.
  """
  def list(opts \\ []) do
    @endpoint
    |> HTTPClient.get(opts)
    |> parse_response(:customer_list)
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Customer.
  See 'ConectaEx.StructList.request_next/2' for examples.
  """
  def next_page(struct_list, limit \\ nil, opts \\ []) do
    struct_list
    |> StructList.request_next(limit, opts)
    |> parse_response(:customer_list)
  end

  @doc ~S"""
  Gets a ConektaEx.StructList with 'data' as a list of
  ConektaEx.Customer.
  See 'ConectaEx.StructList.request_previous/2' for examples.
  """
  def previous_page(struct_list, limit \\ nil, opts \\ []) do
    struct_list
    |> StructList.request_previous(limit, opts)
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
  def retrieve(customer_id, opts \\ []) when is_binary(customer_id) do
    "#{@endpoint}/#{customer_id}"
    |> HTTPClient.get(opts)
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
  def create(attrs, opts \\ []) when is_map(attrs) do
    body = Poison.encode!(attrs)

    @endpoint
    |> HTTPClient.post(body, opts)
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
  def update(customer_id, attrs, opts \\ [])
      when is_binary(customer_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{customer_id}"
    |> HTTPClient.put(body, opts)
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
  def delete(customer_id, opts \\ []) when is_binary(customer_id) do
    "#{@endpoint}/#{customer_id}"
    |> HTTPClient.delete(opts)
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
  def create_payment_source(customer_id, type, token_id, opts \\ [])
      when is_binary(customer_id) do
    body = Poison.encode!(%{type: type, token_id: token_id})

    "#{@endpoint}/#{customer_id}/payment_sources/"
    |> HTTPClient.post(body, opts)
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
  def update_payment_source(customer_id, source_id, attrs, opts \\ [])
      when is_binary(customer_id) and is_binary(source_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{customer_id}/payment_sources/#{source_id}"
    |> HTTPClient.put(body, opts)
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
  def delete_payment_source(customer_id, source_id, opts \\ [])
      when is_binary(customer_id) and is_binary(source_id) do
    "#{@endpoint}/#{customer_id}/payment_sources/#{source_id}"
    |> HTTPClient.delete(opts)
    |> parse_response(:payment_source)
  end

  @doc ~S"""
  Creates a shipping contact for a customer with customer_id

  ## Examples

      iex> create_shipping_contact(customer_id, ok_attrs)
      {:ok, %ConektaEx.ShippingContact{}}

      iex> create_shipping_contact(customer_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def create_shipping_contact(customer_id, attrs, opts \\ [])
      when is_binary(customer_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{customer_id}/shipping_contacts"
    |> HTTPClient.post(body, opts)
    |> parse_response(:shipping_contact)
  end

  @doc ~S"""
  Updates a shipping contact for a customer with customer_id and contact_id
  ## Examples

      iex> update_shipping_contact(customer_id, contact_id, ok_attrs)
      {:ok, %ConektaEx.ShippingContact{}}

      iex> update_shipping_contact(customer_id, contact_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update_shipping_contact(customer_id, contact_id, attrs, opts \\ [])
      when is_binary(customer_id) and is_binary(contact_id) and is_map(attrs) do
    body = Poison.encode!(attrs)

    "#{@endpoint}/#{customer_id}/shipping_contacts/#{contact_id}"
    |> HTTPClient.put(body, opts)
    |> parse_response(:shipping_contact)
  end

  @doc ~S"""
  Deletes a shipping contact for a customer with customer_id and contact_id

  ## Examples

      iex> delete_shipping_contact(customer_id, contact_id)
      {:ok, %ConektaEx.ShippingContact{}}

      iex> delete_shipping_contact(customer_id, bad_line_id)
      {:error, %ConektaEx.Error{}}
  """
  def delete_shipping_contact(customer_id, contact_id, opts \\ [])
      when is_binary(customer_id) and is_binary(contact_id) do
    "#{@endpoint}/#{customer_id}/shipping_contacts/#{contact_id}"
    |> HTTPClient.delete(opts)
    |> parse_response(:shipping_contact)
  end

  @doc ~S"""
  Creates a subscription for a customer with customer_id,
  plan_id and card_id if proivded.

  ## Examples

      iex> create_subscription(customer_id, ok_plan_id)
      {:ok, %ConektaEx.Subscription{}}

      iex> create_subscription(customer_id, bad_plan_id)
      {:error, %ConektaEx.Error{}}
  """
  def create_subscription(customer_id, plan_id, card_id \\ nil, opts \\ [])
      when is_binary(customer_id) and is_binary(plan_id) do
    body =
      case card_id do
        nil -> %{}
        c_id -> Map.put(%{}, :card, c_id)
      end
      |> Map.put(:plan, plan_id)
      |> Poison.encode!()

    "#{@endpoint}/#{customer_id}/subscription"
    |> HTTPClient.post(body, opts)
    |> parse_response(:subscription)
  end

  @doc ~S"""
  Updates a subscription for a customer with customer_id,
  plan_id and card_id if proivded.

  ## Examples

      iex> update_subscription(customer_id, plan_id, ok_attrs)
      {:ok, %ConektaEx.Subscription{}}

      iex> update_subscription(customer_id, plan_id, bad_attrs)
      {:error, %ConektaEx.Error{}}
  """
  def update_subscription(customer_id, plan_id, card_id \\ nil, opts \\ [])
      when is_binary(customer_id) and is_binary(plan_id) do
    body =
      case card_id do
        nil -> %{}
        c_id -> Map.put(%{}, :card, c_id)
      end
      |> Map.put(:plan, plan_id)
      |> Poison.encode!()

    "#{@endpoint}/#{customer_id}/subscription"
    |> HTTPClient.put(body, opts)
    |> parse_response(:subscription)
  end

  @doc ~S"""
  Pauses a subscription with subscription_id for a customer_id

  ## Examples

      iex> pause_subscription(customer_id, ok_subscription_id)
      {:ok, %ConektaEx.Subscription{}}

      iex> pause_subscription(customer_id, bad_subscription_id)
      {:error, %ConektaEx.Error{}}
  """
  def pause_subscription(customer_id, subscription_id, opts \\ [])
      when is_binary(customer_id) and is_binary(subscription_id) do
    body = Poison.encode!(%{id: subscription_id})

    "#{@endpoint}/#{customer_id}/subscription/pause"
    |> HTTPClient.post(body, opts)
    |> parse_response(:subscription)
  end

  @doc ~S"""
  Resumes a subscription with subscription_id for a customer_id

  ## Examples

      iex> resume_subscription(customer_id, ok_subscription_id)
      {:ok, %ConektaEx.Subscription{}}

      iex> resume_subscription(customer_id, bad_subscription_id)
      {:error, %ConektaEx.Error{}}
  """
  def resume_subscription(customer_id, subscription_id, opts \\ [])
      when is_binary(customer_id) and is_binary(subscription_id) do
    body = Poison.encode!(%{id: subscription_id})

    "#{@endpoint}/#{customer_id}/subscription/resume"
    |> HTTPClient.post(body, opts)
    |> parse_response(:subscription)
  end

  @doc ~S"""
  Cancels a subscription with subscription_id for a customer_id

  ## Examples

      iex> cancel_subscription(customer_id, ok_subscription_id)
      {:ok, %ConektaEx.Subscription{}}

      iex> cancel_subscription(customer_id, bad_subscription_id)
      {:error, %ConektaEx.Error{}}
  """
  def cancel_subscription(customer_id, subscription_id, opts \\ [])
      when is_binary(customer_id) and is_binary(subscription_id) do
    body = Poison.encode!(%{id: subscription_id})

    "#{@endpoint}/#{customer_id}/subscription/cancel"
    |> HTTPClient.post(body, opts)
    |> parse_response(:subscription)
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

  defp parse_response({:ok, res}, :shipping_contact) do
    struct = %ShippingContact{address: %Address{}}
    {:ok, Poison.decode!(res.body, as: struct)}
  end

  defp parse_response({:ok, res}, :subscription) do
    {:ok, Poison.decode!(res.body, as: %Subscription{})}
  end

  defp response() do
    %__MODULE__{
      payment_sources: %StructList{
        data: [%PaymentSource{address: %Address{}}]
      },
      shipping_contacts: %StructList{
        data: [%ShippingContact{address: %Address{}}]
      },
      subscription: %Subscription{}
    }
  end
end
