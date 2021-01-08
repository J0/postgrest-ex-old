defmodule PostgrestexTest do
  use ExUnit.Case
  doctest Postgrestex
  import Postgrestex

  test "constructor creates default headers" do
    session_headers = MapSet.new(init("public").headers)

    default_headers =
      MapSet.new(%{
        Accept: "application/json",
        "Content-Type": "application/json",
        "Accept-Profile": "public",
        "Content-Profile": "public"
      })

    assert MapSet.subset?(default_headers, session_headers)
  end

  test "create query" do
    resp =
      init("public")
      |> from("users")
      |> insert(
        %{username: "nevergonna", age_range: "[1,2)", status: "ONLINE", catchphrase: "giveyouup"},
        False
      )
      |> call()

    assert(
      resp.request.body ==
        "{\"age_range\":\"[1,2)\",\"catchphrase\":\"giveyouup\",\"status\":\"ONLINE\",\"username\":\"nevergonna\"}"
    )
  end

  # Read query from
  test "read query" do
    # @TODO: Create test
    # IO.inspect(init("api") |> from("todos") |> select(["id", "name"]))
  end

  test "multivalued params work" do
    # @TODO: Create test
    # init("api") |> lte("x", "a") |> gte("x", "b")
  end

  test "update query" do
    # @TODO: Create test
    # init("public") |> from("users") |> eq("id", "1") |> update(%{id: "5"})
  end

  test "delete query" do
    # @TODO: Create test
    # init("public")
    # |> from("users")
    # |> eq("name", "Singapore")
    # |> delete(%{id: 1})
    # |> auth("<insert your token here>")
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

  describe "Test schema change" do
    req = init("todo")
    session = schema(req, "private")
    session_headers = MapSet.new(session.headers)

    subheaders =
      MapSet.new(%{
        "Accept-Profile": "private",
        "Content-Profile": "private"
      })

    assert(MapSet.subset?(subheaders, session_headers))
  end

  describe "Test insert variants" do
    test "Insert insert" do
      # @TODO: Add test here
    end

    test "Test Upsert" do
      # @TODO: Add test here
    end

    test "Test Update" do
      # @TODO: Add test here
    end

    test "Test Delete" do
      # @TODO: Add test here
    end
  end
end
