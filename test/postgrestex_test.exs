defmodule PostgrestexTest do
  use ExUnit.Case
  doctest Postgrestex
  import Postgrestex

  test "constructor creates default headers" do
    session_headers = MapSet.new(init("todos").headers)

    default_headers =
      MapSet.new(%{
        Accept: "application/json",
        "Content-Type": "application/json",
        "Accept-Profile": "todos",
        "Content-Profile": "todos"
      })

    assert MapSet.subset?(default_headers, session_headers)
  end

  test "create query" do
    # @TODO: Create test
    init("api")
    |> from("todos")
    |> insert(%{name: "Singapore", capital: "Singapore"}, False)
  end

  # Read query from
  test "read query" do
    # @TODO: Create test
    init("api") |> from("todos") |> select(["id", "name"])
  end

  test "multivalued params work" do
    # @TODO: Create test
    init("api") |> lte("x", "a") |> gte("x", "b")
  end

  test "update query" do
    # @TODO: Create test
    init("api")
    |> from("todos")
    |> eq("id", "1")
    |> update(%{id: "5"})
    |> auth("<insert your token here>")
  end

  test "delete query" do
    # @TODO: Create test
    init("api")
    |> from("todos")
    |> eq("name", "Singapore")
    |> delete(%{id: 1})
    |> auth("<insert your token here>")
  end

  # Integration test for limit query and range query together with a not clause
  test "selectors work" do
    # @TODO: Create test
  end

  test "update headers inserts a header" do
    assert(update_headers(init("api"), %{new_header: "header"}).headers.new_header == "header")
  end

  describe "Authentication tests" do
    test "test auth token" do
      # @TODO: Add test here
    end

    test "test auth basic" do
      # @TODO: Add test here
    end
  end

  describe "Test schema" do
    # @TODO: Add test here
  end
end
