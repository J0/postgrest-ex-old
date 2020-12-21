defmodule Client do
  @moduledoc """
  Documentation for `Postgrestex`.
  """

  @doc """
  Authenticate the client with either the bearer token or basic authentication

  ## Examples

      iex> Client.auth()
      :world

  """
  @spec init(map(), String.t()) :: map()
  def init(schema, path \\ "http://localhost:3000") do
    %{
      headers: %{
        Accept: "application/json",
        "Content-Type": "application/json",
        "Accept-Profile": schema,
        "Content-Profile": schema
      },
      path: path,
      schema: schema,
      method: "GET",
      negate_next: False,
      body: %{},
      params: %{}
    }
  end

  @spec auth(map(), String.t(), String.t(), String.t()) :: String.t()
  def auth(req, token, username \\ nil, password \\ "") do
    # authenticate using the hackney client
    hackney = [basic_auth: {username, password}]
    # add the auth bearer token
    ""
  end

  @doc """
  Switch to another schema.

  ## Examples

      iex> Client.schema()
      :schema
  """
  @spec schema(map(), String.t()) :: map()
  def schema(req, schema) do
    Map.merge(req, %{schema: schema, method: "GET"})
  end

  @doc """
  Perform a table operation

  ## Examples

    iex> Client.from()
    :from

  """
  @spec from(map(), String.t()) :: map()
  def from(req, table) do
    Map.merge(req, %{path: "#{req.path}/#{table}"})
  end

  @spec rpc(map(), String.t(), map()) :: map()
  def rpc(req, func, params) do
    # Append to path and set req type to post 
    Map.merge(req, %{path: "#{req.path}/#{func}", body: params, method: "POST"})
  end

  @spec call(map()) :: :ok | :error
  def call(req) do
    url = req.path
    headers = req.headers
    body = Poison.encode!(Map.get(req, :body, %{}))
    params = Map.get(req, :params, %{})

    case req.method do
      "POST" -> HTTPoison.post!(url, body, headers, params: params)
      "GET" -> HTTPoison.get!(url, headers)
      "PATCH" -> HTTPoison.patch!(url, %{}, headers, params: params)
      "DELETE" -> HTTPoison.delete!(url, params: params)
      _ -> IO.puts("Method not found!")
    end
  end
end
