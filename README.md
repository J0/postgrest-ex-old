
# Postgrestex

**Status: POC**


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
- [ ] Test multivalue params as well as selectors 
- [ ] Figure out how auth works within Postgrest


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
```
init("public") |> from("users") |> eq("username", "supabot") |> update(%{"status": "OFFLINE"}) |> call()
```

### Delete
Example usage:

```
init("public")
  |> from("users")
  |> eq("username", "nevergonna")
  |> delete(%{status: "ONLINE"})
  |> call!()
```

## Testing

Run `mix test`


