defmodule ConektaEx.CustomerTest do
  use ExUnit.Case
  alias ConektaEx.{Error, Customer, StructList}

  @valid_params %{
    name: "luis",
    email: "luis@luis.com"
  }

  @invalid_params %{
    email: nil
  }

  setup do
    assert {:ok, customer} = Customer.create(@valid_params)
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
    assert {:error, %HTTPoison.Error{} = err} =
             Customer.previous_page(%StructList{next_page_url: nil}, 1)

    assert err.reason == :nxdomain
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
    assert {:error, %HTTPoison.Error{} = err} =
             Customer.previous_page(%StructList{previous_page_url: nil}, 1)

    assert err.reason == :nxdomain
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
end
