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
    {:ok, resp} =
      init("public")
      |> from("users")
      |> insert(
        %{username: "nevergonna", age_range: "[1,2)", status: "ONLINE", catchphrase: "giveyouup"},
        false
      )
      |> call()

    assert(resp.request.body =~ "nevergonna")
  end

  test "read query" do
    {:ok, %HTTPoison.Response{status_code: status_code, body: body}} =
      init("public") |> from("messages") |> select(["id", "username"]) |> call()

    [row | _rest] = Jason.decode!(body, keys: :atoms)
    assert(status_code == 200)
    assert(Map.keys(row) |> Enum.sort() == [:id, :username])
  end

  test "multivalued params work" do
    {:ok, resp} = init("public") |> from("messages") |> lte("id", "1") |> gte("id", "1") |> call()
    assert(resp.status_code == 200 && resp.request.params == [{"id", "gte.1"}, {"id", "lte.1"}])
  end

  test "update query" do
    init("public")
    |> from("users")
    |> eq("username", "dragarcia")
    |> update(%{username: "supabase"})
    |> call()

    {:ok, resp} = init("public") |> from("users") |> select(["status", "username"]) |> call()
    assert(resp.body =~ "supabase")
  end

  test "delete query" do
    {:ok, resp} =
      init("public")
      |> from("users")
      |> eq("username", "awailas")
      |> eq("status", "ONLINE")
      |> delete()
      |> call()

    assert(resp.status_code == 204)
  end

  test "delete returns row" do
    {:ok, %HTTPoison.Response{status_code: status_code, body: body}} =
      init("public")
      |> from("users")
      |> eq("username", "nevergonna")
      |> delete(returning: true)
      |> call()

    assert(status_code == 200)
    body = Jason.decode!(body, keys: :atoms)
    assert(length(body) == 1)
    [user] = body
    assert(user.username == "nevergonna")
  end

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

  test "Test Upsert after regular insertion" do
    init("public")
    |> from("users")
    |> insert(
      %{username: "nevergonna", age_range: "[1,2)", status: "ONLINE", catchphrase: "giveyouup"},
      false
    )
    |> call()

    {:ok, resp} =
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
