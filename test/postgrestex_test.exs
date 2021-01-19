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
    resp = init("public") |> from("messages") |> select(["id", "username"]) |> call()
    assert(resp.status_code == 200)
  end

  test "multivalued params work" do
    # Update does not work
    # init("public") |> from("messages") |> lte("id", "1") |> gte("id", "1") |> call()
  end

  test "update query" do
    init("public")
    |> from("messages")
    |> eq("username", "supabot")
    |> update(%{id: "6"})
    |> call()

    resp = init("public") |> from("messages") |> select(["id", "username"]) |> call()
    assert(resp.body =~ "\"id\":5")
  end

  test "delete query" do
    resp =
      init("public")
      |> from("users")
      |> eq("username", "awailas")
      |> delete(%{status: "ONLINE"})
      |> call()

    assert(resp.status_code == 204)
  end

  # Integration test for limit query and range query together with a not clause
  test "selectors work" do
    # @TODO: Create test
  end

  test "update headers inserts a header" do
    assert(update_headers(init("api"), %{new_header: "header"}).headers.new_header == "header")
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
      init("public")
      |> from("users")
      |> eq("username", "supabot")
      |> insert(%{random: "field"})
      |> call()
    end

    test "Test Upsert" do
      # @TODO: Add test here
    end

    test "Test Update" do
      # This should successfully update
      req =
        init("public")
        |> from("users")
        |> eq("username", "supabot")
        |> update(%{status: "OFFLINE"})

      assert(req.params == %{"username" => "eq.supabot"})
      assert(req.method == "PATCH")
      assert(req.headers[:Prefer] == "return=representation")
    end

    test "Test Delete" do
      # The object should be deleted
      req =
        init("public")
        |> from("users")
        |> eq("username", "nevergonna")
        |> delete(%{status: "ONLINE"})

      assert(req.method == "DELETE")
      assert(req.body == %{status: "ONLINE"})
    end
  end

  describe "Authentication tests" do
    test "test auth token" do
      # @TODO: Add test here
    end

    test "test auth basic" do
      # @TODO: Add test here
    end
  end
end
