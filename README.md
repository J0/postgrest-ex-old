# Postgrestex

Elixir Postgrestex library for Postgrest. The design mirrors that of [postgrest-py](https://github.com/supabase/postgrest-py)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `postgrestex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:postgrestex, "~> 0.1.0"}
  ]
end
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/postgrestex](https://hexdocs.pm/postgrestex).

## Getting Started


TODOS:
- [x] Support Select Requests
- [ ] Write Tests
- [ ] Support Auth
- [ ] Document all functions
- [ ] Convert to use async library

## Initialize and read from a table
```
 Postgrestex.init("api") |> Postgrestex.from("todos") |> Postgrestex.call()
```

### Create
```
Postgrestex.init("api") |> Postgrestex.from("todos") |> Postgrestex.insert(%{"name": "Singapore", "capital": "Singapore" }, False) |> Postgrestex.call()
```

### Read
```
Postgrestex.init("api") |> Postgrestex.from("todos") |> Postgrestex.select(["id", "name"]) |>Postgrestex.call()
```

### Update
Note: Bear in mind to update the <insert your token field> to use your own jwt token.
```
Postgrestex.init("api") |> Postgrestex.from("todos") |> Postgrestex.eq("id", "1") |> Postgrestex.update(%{"id": "5"}) |> Postgrestex.auth("<insert your token here>") Postgrestex.call()
```

### Delete
Note: Bear in mind to update the <insert your token field> to use your own jwt token.
```
Postgrestex.init("api") |> Postgrestex.from("todos") |> Postgrestex.eq("name", "Singapore") |> Postgrestex.delete(%{"id": 1})|> Postgrestex.auth("<insert your token here>") |> Postgrestex.call()
```


