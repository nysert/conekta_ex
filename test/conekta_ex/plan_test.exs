defmodule ConektaEx.PlanTest do
  use ExUnit.Case
  alias ConektaEx.{Error, Plan, StructList}

  @valid_params %{
    name: "luis-plan",
    amount: 300,
    currency: "MXN",
    interval: "month",
    frequency: 1,
    trial_period_days: 15,
    expiry_count: nil
  }

  @invalid_params %{
    name: nil,
    amount: 200,
    currency: nil,
    interval: nil,
    frequency: nil,
    trial_period_days: nil,
    expiry_count: nil
  }

  setup do
    assert {:ok, plan} = Plan.create(@valid_params)
    {:ok, plan: plan}
  end

  test "list/0 returns {:ok, %StructList{}}" do
    assert {:ok, %StructList{} = sl} = Plan.list()
    assert sl.object == "list"
    assert is_list(sl.data)
  end

  test "next_page/2 returns {:ok, %StructList{}} with valid params" do
    assert {:ok, %StructList{} = sl0} = Plan.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Plan.next_page(sl0, 1)
    assert sl1.object == "list"
  end

  test "next_page/2 returns {:error, %HTTPoison.Error{}} with invalid url" do
    assert_raise RuntimeError, "request error, nxdomain", fn ->
      Plan.previous_page(%StructList{next_page_url: ""}, 1)
    end
  end

  test "next_page/2 returns {:error, %ConektaEx.Error{}} with invalid limit" do
    assert {:ok, %StructList{} = sl0} = Plan.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:error, %Error{}} = Plan.next_page(sl0, 10000)
  end

  test "previous_page/2 returns {:ok, %StructList{}} with valid params" do
    assert {:ok, %StructList{} = sl0} = Plan.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Plan.next_page(sl0, 1)
    assert is_binary(sl1.previous_page_url)
    assert {:ok, %StructList{} = sl2} = Plan.previous_page(sl1)
    assert sl2.object == "list"
  end

  test "previous_page/2 returns {:error, %HTTPoison.Error{}} with invalid url" do
    assert_raise RuntimeError, "request error, nxdomain", fn ->
      Plan.previous_page(%StructList{previous_page_url: ""}, 1)
    end
  end

  test "previous_page/2 returns {:error, %ConektaEx.Error{}} with invalid limit" do
    assert {:ok, %StructList{} = sl0} = Plan.list()
    assert sl0.object == "list"
    assert is_binary(sl0.next_page_url)
    assert {:ok, %StructList{} = sl1} = Plan.next_page(sl0, 1)
    assert is_binary(sl1.previous_page_url)
    assert {:error, %Error{}} = Plan.previous_page(sl1, 10000)
  end

  test "retrieve/1 returns {:ok, %Plan{}} with valid id", %{plan: p} do
    assert {:ok, %Plan{}} = Plan.retrieve(p.id)
  end

  test "retrieve/1 returns {:error, %Error{}} with invalid id" do
    assert {:error, %Error{}} = Plan.retrieve("invalid_id")
  end

  test "create/1 returns {:ok, %Plan{}} with valid attrs" do
    assert {:ok, %Plan{} = c} = Plan.create(@valid_params)
    assert c.name == @valid_params.name
    assert c.amount == @valid_params.amount
  end

  test "create/1 returns {:error, %Error{}} with invalid attrs" do
    assert {:error, %Error{}} = Plan.create(@invalid_params)
  end

  test "update/1 returns {:ok, %Plan{}} with valid attrs", %{plan: p} do
    attrs = %{amount: 400}
    assert {:ok, %Plan{} = c} = Plan.update(p.id, attrs)
    assert c.amount == attrs.amount
  end

  test "update/1 returns {:error, %Error{}} with invalid attrs", %{plan: p} do
    assert {:error, %Error{} = c} = Plan.update(p.id, @invalid_params)
    assert c.object == "error"
    assert c.type == "parameter_validation_error"
  end

  test "delete/1 returns {:ok, plan} with valid id", %{plan: p} do
    assert {:ok, %Plan{} = deleted_c} = Plan.delete(p.id)
    assert deleted_c.name == p.name
    assert deleted_c.id == p.id
  end

  test "delete/1 returns {:error, err} with invalid id" do
    assert {:error, %Error{} = e} = Plan.delete("invalid_id")
    assert e.object == "error"
    assert e.type == "resource_not_found_error"
  end
end
