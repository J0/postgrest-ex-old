
# Postgrestex

**Status: WIP(Do Not Use!)**


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
- [ ] Write Tests
- [ ] Document all functions
- [ ] Convert to use async library

## Initialize and read from a table

First, `import Postgrestex`

Then do any one of the following options:

### Create
```
init("api") |> from("todos") |> insert(%{"name": "Singapore", "capital": "Singapore" }, False) |> call()
```

### Read
```
init("api") |> from("todos") |> select(["id", "name"]) |> call()
```

### Update
Note: Bear in mind to update the <insert your token field> to use your own jwt token.
```
init("api") |> from("todos") |> eq("id", "1") |> update(%{"id": "5"}) |> auth("<insert your token here>")|> call()
```

### Delete
Note: Bear in mind to update the <insert your token field> to use your own jwt token.
```
init("api") |> from("todos") |> eq("name", "Singapore") |> delete(%{"id": 1}) |> auth("<insert your token here>") |> call()
```

## Testing

Run `mix test`


