defmodule ConektaEx.OrderTest do
  use ExUnit.Case
  alias ConektaEx.{Error, Order, StructList, Customer}

  @customer_attrs %{
    name: "cus",
    email: "cus@cus.com",
    payment_sources: [
      %{
        token_id: "tok_test_visa_4242",
        type: "card"
      }
    ]
  }

  @valid_params %{
    currency: "MXN",
    customer_info: %{},
    line_items: [
      %{
        name: "Box of Cohiba S1s",
        unit_price: 35000,
        quantity: 1
      }
    ],
    charges: [
      %{payment_method: %{type: "default"}}
    ]
  }

  @invalid_params %{
    email: nil
  }

  setup do
    assert {:ok, customer} = Customer.create(@customer_attrs)
    customer_info = Map.put(%{}, :customer_id, customer.id)
    order_attrs = Map.put(@valid_params, :customer_info, customer_info)
    assert {:ok, order} = Order.create(order_attrs)
    {:ok, order: order}
  end

  test "list/0 returns {:ok, %StructList{}}" do
    assert {:ok, %StructList{} = sl} = Order.list()
    assert sl.object == "list"
    assert is_list(sl.data)
  end

  test "next_page/2 returns {:ok, %StructList{}} with valid params" do
    assert {:ok, %StructList{} = sl0} = Order.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Order.next_page(sl0, 1)
    assert sl1.object == "list"
  end

  test "next_page/2 returns {:error, %HTTPoison.Error{}} with invalid url" do
    assert {:error, %HTTPoison.Error{} = err} =
             Order.previous_page(%StructList{next_page_url: nil}, 1)

    assert err.reason == :nxdomain
  end

  test "next_page/2 returns {:error, %ConektaEx.Error{}} with invalid limit" do
    assert {:ok, %StructList{} = sl0} = Order.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:error, %Error{}} = Order.next_page(sl0, 10000)
  end

  test "previous_page/2 returns {:ok, %StructList{}} with valid params" do
    assert {:ok, %StructList{} = sl0} = Order.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Order.next_page(sl0, 1)
    assert is_binary(sl1.previous_page_url)
    assert {:ok, %StructList{} = sl2} = Order.previous_page(sl1)
    assert sl2.object == "list"
  end

  test "previous_page/2 returns {:error, %HTTPoison.Error{}} with invalid url" do
    assert {:error, %HTTPoison.Error{} = err} =
             Order.previous_page(%StructList{previous_page_url: nil}, 1)

    assert err.reason == :nxdomain
  end

  test "previous_page/2 returns {:error, %ConektaEx.Error{}} with invalid limit" do
    assert {:ok, %StructList{} = sl0} = Order.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Order.next_page(sl0, 1)
    assert is_binary(sl1.previous_page_url)
    assert {:error, %Error{}} = Order.previous_page(sl1, 10000)
  end

  test "retrieve/1 returns {:ok, %Order{}} with valid id", %{order: o} do
    assert {:ok, %Order{}} = Order.retrieve(o.id)
  end

  test "retrieve/1 returns {:error, %Error{}} with invalid id" do
    assert {:error, %Error{}} = Order.retrieve("invalid_id")
  end

  test "create/1 returns {:ok, %Order{}} with valid attrs" do
    assert {:ok, customer} = Customer.create(@customer_attrs)
    customer_info = Map.put(%{}, :customer_id, customer.id)
    order_attrs = Map.put(@valid_params, :customer_info, customer_info)
    assert {:ok, %Order{} = o} = Order.create(order_attrs)
    assert o.amount == 35000
    assert o.currency == "MXN"
  end

  test "create/1 returns {:error, %Error{}} with invalid attrs" do
    assert {:error, %Error{}} = Order.create(@invalid_params)
  end

  test "create_charge/1 returns {:ok, %Order{}} with valid attrs", %{order: o} do
    attrs = %{payment_method: %{type: "card", token_id: "tok_test_visa_4242"}}
    assert {:ok, %Order{}} = Order.create_charge(o.id, attrs)
  end

  test "create_charge/1 returns {:eror, %Error{}} with invalid attrs" do
    attrs = %{payment_method: %{type: "card", token_id: "tok_test_visa_4242"}}
    assert {:error, %Error{} = e} = Order.create_charge("", attrs)
    assert e.object == "error"
    assert e.type == "parameter_validation_error"
  end
end
