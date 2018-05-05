defmodule ConektaEx.CustomerTest do
  use ExUnit.Case
  alias ConektaEx.Error
  alias ConektaEx.Customer
  alias ConektaEx.StructList
  alias ConektaEx.PaymentSource
  alias ConektaEx.Subscription
  alias ConektaEx.ShippingContact

  @shipping_contact %{
    address: %{
      city: "Ciudad de Mexico",
      country: "mx",
      object: "shipping_address",
      postal_code: "78215",
      residential: true,
      state: "Ciudad de Mexico",
      street1: "Nuevo Leon 4",
      street2: "nuevo leon 5"
    },
    between_streets: "Campeche y Morelos",
    phone: "+52000000000000",
    receiver: "Mario perez"
  }

  @valid_params %{
    name: "luis",
    email: "luis@luis.com",
    payment_sources: [
      %{
        token_id: "tok_test_visa_4242",
        type: "card"
      }
    ],
    shipping_contacts: [
      @shipping_contact
    ]
  }

  @invalid_params %{
    email: nil
  }

  setup do
    assert {:ok, customer} = Customer.create(@valid_params)
    ps = customer.payment_sources
    assert ps.object == "list"
    assert is_list(ps.data)
    {:ok, customer: customer}
  end

  test "list/0 returns {:ok, %StructList{}}" do
    assert {:ok, %StructList{} = sl} = Customer.list()
    assert sl.object == "list"
    assert is_list(sl.data)
  end

  test "next_page/2 returns {:ok, %StructList{}} with valid params" do
    assert {:ok, %StructList{} = sl0} = Customer.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Customer.next_page(sl0, 1)
    assert sl1.object == "list"
  end

  test "next_page/2 returns {:error, %HTTPoison.Error{}} with invalid url" do
    assert_raise RuntimeError, "request error, nxdomain", fn ->
      Customer.previous_page(%StructList{next_page_url: ""}, 1)
    end
  end

  test "next_page/2 returns {:error, %ConektaEx.Error{}} with invalid limit" do
    assert {:ok, %StructList{} = sl0} = Customer.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:error, %Error{}} = Customer.next_page(sl0, 10000)
  end

  test "previous_page/2 returns {:ok, %StructList{}} with valid params" do
    assert {:ok, %StructList{} = sl0} = Customer.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Customer.next_page(sl0, 1)
    assert is_binary(sl1.previous_page_url)
    assert {:ok, %StructList{} = sl2} = Customer.previous_page(sl1)
    assert sl2.object == "list"
  end

  test "previous_page/2 returns {:error, %HTTPoison.Error{}} with invalid url" do
    assert_raise RuntimeError, "request error, nxdomain", fn ->
      Customer.previous_page(%StructList{previous_page_url: ""}, 1)
    end
  end

  test "previous_page/2 returns {:error, %ConektaEx.Error{}} with invalid limit" do
    assert {:ok, %StructList{} = sl0} = Customer.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Customer.next_page(sl0, 1)
    assert is_binary(sl1.previous_page_url)
    assert {:error, %Error{}} = Customer.previous_page(sl1, 10000)
  end

  test "retrieve/1 returns {:ok, %Customer{}} with valid id", %{customer: c} do
    assert {:ok, %Customer{}} = Customer.retrieve(c.id)
  end

  test "retrieve/1 returns {:error, %Error{}} with invalid id" do
    assert {:error, %Error{}} = Customer.retrieve("invalid_id")
  end

  test "create/1 returns {:ok, %Customer{}} with valid attrs" do
    assert {:ok, %Customer{} = c} = Customer.create(@valid_params)
    assert c.name == @valid_params.name
    assert c.email == @valid_params.email
  end

  test "create/1 returns {:error, %Error{}} with invalid attrs" do
    assert {:error, %Error{}} = Customer.create(@invalid_params)
  end

  test "update/1 returns {:ok, %Customer{}} with valid attrs", %{customer: c} do
    attrs = %{name: "siul"}
    assert {:ok, %Customer{} = c} = Customer.update(c.id, attrs)
    assert c.name == "siul"
  end

  test "update/1 returns {:error, %Error{}} with invalid attrs", %{customer: c} do
    assert {:error, %Error{} = c} = Customer.update(c.id, @invalid_params)
    assert c.object == "error"
    assert c.type == "parameter_validation_error"
  end

  test "delete/1 returns {:ok, customer} with valid id", %{customer: c} do
    assert {:ok, %Customer{} = deleted_c} = Customer.delete(c.id)
    assert deleted_c.name == c.name
    assert deleted_c.email == c.email
  end

  test "delete/1 returns {:error, err} with invalid id" do
    assert {:error, %Error{} = e} = Customer.delete("invalid_id")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "create_payment_source/3 returns {:ok, source} with valid params", %{customer: c} do
    assert {:ok, %PaymentSource{} = src} =
             Customer.create_payment_source(c.id, "card", "tok_test_visa_4242")

    assert src.brand == "VISA"
    assert src.object == "payment_source"
    assert src.type == "card"
  end

  test "create_payment_source/3 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.create_payment_source(c.id, "card", "token")
    assert e.object == "error"
    assert e.type == "parameter_validation_error"
  end

  test "update_payment_source/3 returns {:ok, source} with valid params", %{customer: c} do
    ps_id = c.payment_sources.data |> Enum.at(0) |> Map.get(:id)
    attrs = %{exp_month: "1", name: "new name"}
    assert {:ok, %PaymentSource{} = src} = Customer.update_payment_source(c.id, ps_id, attrs)
    assert src.brand == "VISA"
    assert src.object == "payment_source"
    assert src.type == "card"
    assert src.name == "new name"
    assert src.exp_month == "1"
  end

  test "update_payment_source/3 returns {:error, error} with valid params", %{customer: c} do
    ps_id = c.payment_sources.data |> Enum.at(0) |> Map.get(:id)
    attrs = %{exp_month: 32}
    assert {:error, %Error{} = e} = Customer.update_payment_source(c.id, ps_id, attrs)
    assert e.object == "error"
    assert e.type == "parameter_validation_error"
  end

  test "delete_payment_source/2 returns {:ok, source} with valid params", %{customer: c} do
    ps_id = c.payment_sources.data |> Enum.at(0) |> Map.get(:id)
    assert {:ok, %PaymentSource{} = src} = Customer.delete_payment_source(c.id, ps_id)
    assert src.brand == "VISA"
    assert src.object == "payment_source"
    assert src.type == "card"
  end

  test "delete_payment_source/1 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.delete_payment_source(c.id, "source_id")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "create_shipping_contact/3 returns {:ok, source} with valid params", %{customer: c} do
    assert {:ok, %ShippingContact{} = shp} =
             Customer.create_shipping_contact(c.id, @shipping_contact)

    assert shp.phone == "+52000000000000"
    assert shp.receiver == "Mario perez"
  end

  test "create_shipping_contact/3 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.create_shipping_contact(c.id, %{})
    assert e.object == "error"
    assert e.type == "parameter_validation_error"
  end

  test "update_shipping_contact/3 returns {:ok, source} with valid params", %{customer: c} do
    shp_id = c.shipping_contacts.data |> Enum.at(0) |> Map.get(:id)
    attrs = %{phone: "+55555555555555", receiver: "luis"}
    assert {:ok, %ShippingContact{} = shp} = Customer.update_shipping_contact(c.id, shp_id, attrs)
    assert shp.phone == "+55555555555555"
    assert shp.receiver == "luis"
  end

  test "update_shipping_contact/3 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.update_shipping_contact(c.id, "", %{})
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "delete_shipping_contact/2 returns {:ok, source} with valid params", %{customer: c} do
    shp_id = c.shipping_contacts.data |> Enum.at(0) |> Map.get(:id)
    assert {:ok, %ShippingContact{} = shp} = Customer.delete_shipping_contact(c.id, shp_id)
    assert shp.phone == "+52000000000000"
    assert shp.receiver == "Mario perez"
  end

  test "delete_shipping_contact/1 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.delete_shipping_contact(c.id, "")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "create_subscription/3 returns {:ok, subscription} with valid params", %{customer: c} do
    plan_attrs = %{
      name: "luis-plan",
      amount: 300,
      currency: "MXN",
      interval: "month",
      frequency: 1,
      trial_period_days: 15,
      expiry_count: nil
    }

    assert {:ok, plan} = ConektaEx.Plan.create(plan_attrs)
    assert {:ok, %Subscription{} = sub} = Customer.create_subscription(c.id, plan.id)
    assert sub.object == "subscription"
    assert sub.plan_id == plan.id
  end

  test "create_subscription/3 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.create_subscription(c.id, "")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "update_subscription/3 returns {:ok, subscription} with valid params", %{customer: c} do
    plan_attrs = %{
      name: "luis-plan",
      amount: 300,
      currency: "MXN",
      interval: "month",
      frequency: 1,
      trial_period_days: 15,
      expiry_count: nil
    }

    assert {:ok, plan0} = ConektaEx.Plan.create(plan_attrs)
    assert {:ok, %Subscription{}} = Customer.create_subscription(c.id, plan0.id)
    assert {:ok, plan1} = ConektaEx.Plan.create(%{plan_attrs | amount: 3000})
    assert {:ok, %Subscription{} = sub} = Customer.update_subscription(c.id, plan1.id, plan1)
    assert sub.object == "subscription"
    assert sub.plan_id == plan1.id
  end

  test "update_subscription/3 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.update_subscription(c.id, "", %{})
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "pause_subscription/2 returns {:ok, subscription} with valid params", %{customer: c} do
    plan_attrs = %{
      name: "luis-plan",
      amount: 300,
      currency: "MXN",
      interval: "month",
      frequency: 1,
      trial_period_days: 15,
      expiry_count: nil
    }

    assert {:ok, plan} = ConektaEx.Plan.create(plan_attrs)
    assert {:ok, %Subscription{} = sub0} = Customer.create_subscription(c.id, plan.id)
    assert {:ok, %Subscription{} = sub1} = Customer.pause_subscription(c.id, sub0.id)
    assert sub1.status == "paused"
  end

  test "pause_subscription/2 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.pause_subscription(c.id, "")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "resume_subscription/2 returns {:ok, subscription} with valid params", %{customer: c} do
    plan_attrs = %{
      name: "luis-plan",
      amount: 300,
      currency: "MXN",
      interval: "month",
      frequency: 1,
      expiry_count: nil
    }

    assert {:ok, plan} = ConektaEx.Plan.create(plan_attrs)
    assert {:ok, %Subscription{} = sub0} = Customer.create_subscription(c.id, plan.id)
    assert {:ok, %Subscription{} = sub1} = Customer.pause_subscription(c.id, sub0.id)
    assert {:ok, %Subscription{} = sub2} = Customer.resume_subscription(c.id, sub1.id)
    assert sub2.status == "active"
  end

  test "resume_subscription/2 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.resume_subscription(c.id, "")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "cancel_subscription/2 returns {:ok, subscription} with valid params", %{customer: c} do
    plan_attrs = %{
      name: "luis-plan",
      amount: 300,
      currency: "MXN",
      interval: "month",
      frequency: 1,
      trial_period_days: 15,
      expiry_count: nil
    }

    assert {:ok, plan} = ConektaEx.Plan.create(plan_attrs)
    assert {:ok, %Subscription{} = sub0} = Customer.create_subscription(c.id, plan.id)
    assert {:ok, %Subscription{} = sub1} = Customer.cancel_subscription(c.id, sub0.id)
    assert sub1.status == "canceled"
  end

  test "cancel_subscription/2 returns {:error, error} with valid params", %{customer: c} do
    assert {:error, %Error{} = e} = Customer.cancel_subscription(c.id, "")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end

  test "list_payment_sources/2 returns {:ok, source} with valid params", %{customer: c} do
    assert {:ok, %StructList{} = st} = Customer.list_payment_sources(c.id)
    assert length(st.data) == 1
    assert st.data |> Enum.at(0) |> Map.get(:id) == c.default_payment_source_id
  end

  test "list_payment_sources/2 returns {:error, e} with invalid params" do
    assert {:error, %Error{}} = Customer.list_payment_sources("hi")
  end

  test "retrieve_payment_source/2 returns {:ok, source} with valid params", %{customer: c} do
    assert {:ok, %PaymentSource{} = p} =
             Customer.retrieve_payment_source(c.id, c.default_payment_source_id)

    assert p.id == c.default_payment_source_id
  end

  test "retrieve_payment_source/2 returns {:error, e} with invalid params", %{customer: c} do
    assert {:error, %Error{}} = Customer.retrieve_payment_source(c.id, "hi")
  end
end
