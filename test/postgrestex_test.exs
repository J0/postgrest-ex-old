defmodule PostgrestexTest do
  use ExUnit.Case
  doctest Postgrestex
  import Postgrestex

  # Test the four different types of applications
  # POST, PUT, GET, PATCH
  test "init works" do
    assert init("todos").schema == "todos"
  end

  test "create query" do
    assert (init("api") |> from("todos")).schema == "api"
  end

  # Read query from
  test "read query" do
    raise "Not Implemented"
  end

  test "update query" do
    raise "Not Implemented"
  end

  test "delete query" do
    raise "Not Implemented"
  end

  # Integration test for limit query and range query together with a not clause
  test "selectors work" do
    raise "Not Implemented"
  end

  # test update headerd
  test "update headers inserts a header" do
    assert(update_headers(init("api"), %{new_header: "header"}).headers.new_header) == "header"
  end
end
