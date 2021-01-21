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
        false
      )
      |> call()

    assert(
      resp.request.body ==
        "{\"age_range\":\"[1,2)\",\"catchphrase\":\"giveyouup\",\"status\":\"ONLINE\",\"username\":\"nevergonna\"}"
    )
  end

  test "read query" do
    resp = init("public") |> from("messages") |> select(["id", "username"]) |> call()
    assert(resp.status_code == 200)
  end

  test "multivalued params work" do
    resp = init("public") |> from("messages") |> lte("id", "1") |> gte("id", "1") |> call()
    assert(resp.status_code == 200 && resp.request.params == [{"id", "gte.1"}, {"id", "lte.1"}])
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

  test "Test Delete" do
    req =
      init("public")
      |> from("users")
      |> eq("username", "nevergonna")
      |> delete(%{status: "ONLINE"})

    assert(req.method == "DELETE")
    assert(req.body == %{status: "ONLINE"})
  end

  test "selectors work" do
    req =
      init("public")
      |> from("users")
      |> eq("username", "nevergonna")
      |> delete(%{status: "ONLINE"})
  end

  # Integration test for limit query and range query together with a not clause

  test "update headers inserts a header" do
    assert(update_headers(init("api"), %{new_header: "header"}).headers.new_header == "header")
  end

  describe "Test schema change" do
    req = init("public")
    session = schema(req, "private")
    session_headers = MapSet.new(session.headers)

    subheaders =
      MapSet.new(%{
        "Accept-Profile": "private",
        "Content-Profile": "private"
      })

    assert(MapSet.subset?(subheaders, session_headers))
  end

  describe "Test update variants" do
    test "Test Upsert after regular insertion" do
      init("public")
      |> from("users")
      |> insert(
        %{username: "nevergonna", age_range: "[1,2)", status: "ONLINE", catchphrase: "giveyouup"},
        false
      )
      |> call()

      resp =
        init("public")
        |> from("users")
        |> insert(
          %{
            username: "nevergonna",
            age_range: "[1,2)",
            status: "ONLINE",
            catchphrase: "giveyouout"
          },
          true
        )
        |> call()

      assert(resp.request.body =~ "giveyouout")
      assert(resp.status_code == 201)
    end

    test "Test Update" do
      req =
        init("public")
        |> from("users")
        |> eq("username", "supabot")
        |> update(%{status: "OFFLINE"})

      assert(req.params == [{"username", "eq.supabot"}])
      assert(req.method == "PATCH")
      assert(req.headers[:Prefer] == "return=representation")
    end
  end

  describe "Authentication tests" do
    test "test auth with json web token" do
      req = init("public") |> auth("t0ps3cr3t")
      assert(req.headers[:Authorization] == "Bearer t0ps3cr3t")
    end

    test "test auth basic" do
      req = init("public") |> auth(nil, "admin", "t0ps3cr3t")
      assert(req.options == [hackney: [basic_auth: {"admin", "t0ps3cr3t"}]])
    end
  end
end
