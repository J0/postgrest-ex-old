defmodule Postgrestex do
  @moduledoc """
  `Postgrestex` is a client library which provides elixir bindings to interact with PostgREST. PostgREST in turn
  is a standalone web server that turns your PostgreSQL database directly into a RESTful API.
  """
  @moduledoc since: "0.1.0"

  defmodule NoMethodException do
    defexception message: "No method found!"
  end

  @doc """
  Creates an initial request in the form of a map that the user can work with.
  """
  @doc since: "0.1.0"
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
      negate_next: false,
      body: %{},
      params: []
    }
  end

  @doc """
  Authenticate the client with either the bearer token or basic authentication.
  """
  @spec auth(map(), String.t(), String.t(), String.t()) :: map()
  def auth(req, token, username \\ "", password \\ "") do
    if username != "" do
      Map.merge(
        req,
        %{options: [hackney: [basic_auth: {username, password}]]}
      )
    else
      update_headers(req, %{Authorization: "Bearer #{token}"})
    end
  end

  @doc """
  Switch to another schema.
  """
  @spec schema(map(), String.t()) :: map()
  def schema(req, schema) do
    update_headers(req, %{"Accept-Profile": schema, "Content-Profile": schema})
    |> Map.merge(%{schema: schema, method: "GET"})
  end

  @doc """
  Select table to obtain data from/perform operations on
  """
  @spec from(map(), String.t()) :: map()
  def from(req, table) do
    Map.merge(req, %{path: "#{req.path}/#{table}"})
  end

  @doc """
  Execute a Stored Procedure Call
  """
  @doc since: "0.1.0"
  @spec rpc(map(), String.t(), map()) :: map()
  def rpc(req, func, params) do
    Map.merge(req, %{path: "#{req.path}/#{func}", body: params, method: "POST"})
  end

  @doc """
  Take in and execute a request. Doesn't return an exception if an error is thrown.
  """
  @doc since: "0.1.0"
  @spec call(map()) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  def call(req) do
    url = req.path
    headers = req.headers
    body = Jason.encode!(Map.get(req, :body, %{}))
    params = Map.get(req, :params, [])
    options = Map.get(req, :options, [])

    Task.async(fn ->
      case req.method do
        "POST" -> HTTPoison.post(url, body, headers, params: params, options: options)
        "GET" -> HTTPoison.get(url, headers, params: params, options: options)
        "PATCH" -> HTTPoison.patch(url, body, headers, params: params, options: options)
        "DELETE" -> HTTPoison.delete(url, headers, params: params, options: options)
      end
    end)
    |> Task.await()
  end

  @doc """
  Take in and execute a request. Raises an exception if an error occurs.
  """
  @doc since: "0.1.0"
  @spec call!(map()) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()} | NoMethodException
  def call!(req) do
    url = req.path
    headers = req.headers
    body = Jason.encode!(Map.get(req, :body, %{}))
    params = Map.get(req, :params, [])
    options = Map.get(req, :options, [])

    Task.async(fn ->
      case req.method do
        "POST" ->
          HTTPoison.post!(url, body, headers, params: params, options: options)

        "GET" ->
          HTTPoison.get!(url, headers, params: params, options: options)

        "PATCH" ->
          HTTPoison.patch!(url, body, headers, params: params, options: options)

        "DELETE" ->
          HTTPoison.delete!(url, headers, params: params, options: options)

        _ ->
          raise NoMethodException
      end
    end)
    |> Task.await()
  end

  @spec select(map(), list()) :: map()
  def select(req, columns) do
    update_headers(req, %{select: Enum.join(columns, ","), method: "GET"})
  end

  @doc """
  Insert a row into currently selected table. Does an insert and update if upsert is set to True
  """
  @doc since: "0.1.0"
  @spec insert(map(), list(), true | false) :: map()
  def insert(req, json, upsert \\ false) do
    prefer_option = if upsert, do: ",resolution=merge-duplicates", else: ""
    headers = update_headers(req, %{Prefer: prefer_option})
    req |> Map.merge(headers) |> Map.merge(%{body: json, method: "POST"})
  end

  @doc """
  Update an existing value in the currently selected table.
  """
  @doc since: "0.1.0"
  @spec update(map(), map()) :: map()
  def update(req, json) do
    update_headers(req, %{Prefer: "return=representation"})
    |> Map.merge(%{method: "PATCH", body: json})
  end

  @doc """
  Delete an existing value in the currently selected table.
  """
  @doc since: "0.1.0"
  @spec delete(map()) :: map()
  def delete(req) do
    req |> Map.merge(%{method: "DELETE"})
  end

  @spec order(map(), String.t(), true | false, true | false) :: map()
  def order(req, column, desc \\ false, nullsfirst \\ false) do
    desc = if desc, do: ".desc", else: ""
    nullsfirst = if nullsfirst, do: ".nullsfirst", else: ""
    update_headers(req, %{order: "#{column} #{desc} #{nullsfirst}"})
  end

  @spec limit(map(), integer(), integer()) :: map()
  def limit(req, size, start) do
    update_headers(req, %{Range: "#{start}-#{start + size - 1}", "Range-Unit": "items"})
  end

  @spec range(map(), integer(), integer()) :: map()
  def range(req, start, end_) do
    update_headers(req, %{Range: "#{start}-#{end_ - 1}", "Range-Unit": "items"})
  end

  @spec single(map()) :: map()
  def single(req) do
    # Modify this to use a session header
    update_headers(req, %{Accept: "application/vnd.pgrst.object+json"})
  end

  @doc """
  Remove reserved characters from the parameter string.
  """
  @doc since: "0.1.0"
  @spec sanitize_params(String.t()) :: String.t()
  def sanitize_params(str) do
    reserved_chars = String.graphemes(",.:()")
    if String.contains?(str, reserved_chars), do: str, else: "#{str}"
  end

  @spec sanitize_pattern_params(String.t()) :: String.t()
  def sanitize_pattern_params(str) do
    str |> String.replace("%", "*")
  end

  @doc """
  Either filter in or filter out based on negate_next.
  """
  @doc since: "0.1.0"
  @spec filter(map(), String.t(), String.t(), String.t()) :: map()
  def filter(req, column, operator, criteria) do
    {req, operator} =
      if req.negate_next do
        {Map.update!(req, :negate_next, fn negate_next -> !negate_next end), "not.#{operator}"}
      else
        {req, operator}
      end

    val = "#{operator}.#{criteria}"
    key = sanitize_params(column)
    Kernel.put_in(req[:params], [{key, val} | req[:params]])
  end

  @doc """
  Toggle between filtering in or filtering out.
  """
  @doc since: "0.1.0"
  @spec not map() :: map()
  def not req do
    Map.merge(req, %{negate_next: true})
  end

  @spec eq(map(), String.t(), String.t()) :: map()
  def eq(req, column, value) do
    filter(req, column, "eq", sanitize_params(value))
  end

  @spec neq(map(), String.t(), String.t()) :: map()
  def neq(req, column, value) do
    filter(req, column, "neq", sanitize_params(value))
  end

  @spec gt(map(), String.t(), String.t()) :: map()
  def gt(req, column, value) do
    filter(req, column, "gt", sanitize_params(value))
  end

  @spec lt(map(), String.t(), String.t()) :: map()
  def lt(req, column, value) do
    filter(req, column, "lt", sanitize_params(value))
  end

  @spec lte(map(), String.t(), String.t()) :: map()
  def lte(req, column, value) do
    filter(req, column, "lte", sanitize_params(value))
  end

  @spec gte(map(), String.t(), String.t()) :: map()
  def gte(req, column, value) do
    filter(req, column, "gte", sanitize_params(value))
  end

  @spec is_(map(), String.t(), String.t()) :: map()
  def is_(req, column, value) do
    filter(req, column, "is", sanitize_params(value))
  end

  @spec like(map(), String.t(), String.t()) :: map()
  def like(req, column, pattern) do
    filter(req, column, "like", sanitize_pattern_params(pattern))
  end

  @spec ilike(map(), String.t(), String.t()) :: map()
  def ilike(req, column, pattern) do
    filter(req, column, "is", sanitize_params(pattern))
  end

  @spec fts(map(), String.t(), String.t()) :: map()
  def fts(req, column, query) do
    filter(req, column, "fts", sanitize_params(query))
  end

  @spec plfts(map(), String.t(), String.t()) :: map()
  def plfts(req, column, query) do
    filter(req, column, "plfts", sanitize_params(query))
  end

  @spec phfts(map(), String.t(), String.t()) :: map()
  def phfts(req, column, query) do
    filter(req, column, "phfts", sanitize_params(query))
  end

  @spec wfts(map(), String.t(), String.t()) :: map()
  def wfts(req, column, query) do
    filter(req, column, "wfts", sanitize_params(query))
  end

  def in_(req, column, values) do
    values = Enum.map(fn param -> sanitize_params(param) end, values) |> Enum.join(",")
    filter(req, column, "in", "(#{values})")
  end

  def cs(req, column, values) do
    values = Enum.map(fn param -> sanitize_params(param) end, values) |> Enum.join(",")
    filter(req, column, "cs", "{#{values}}")
  end

  def cd(req, column, values) do
    values = Enum.map(fn param -> sanitize_params(param) end, values) |> Enum.join(",")
    filter(req, column, "cd", "{#{values}}")
  end

  def ov(req, column, values) do
    values = Enum.map(fn param -> sanitize_params(param) end, values) |> Enum.join(",")
    filter(req, column, "ov", "{#{values}}")
  end

  @spec sl(map(), String.t(), integer()) :: map()
  def sl(req, column, range) do
    filter(req, column, "sl", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  @spec sr(map(), String.t(), integer()) :: map()
  def sr(req, column, range) do
    filter(req, column, "sr", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  @spec nxl(map(), String.t(), integer()) :: map()
  def nxl(req, column, range) do
    filter(req, column, "nxl", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  @spec nxr(map(), String.t(), integer()) :: map()
  def nxr(req, column, range) do
    filter(req, column, "nxr", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  @spec adj(map(), String.t(), integer()) :: map()
  def adj(req, column, range) do
    filter(req, column, "adj", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  @spec update_headers(map(), map()) :: map()
  def update_headers(req, updates) do
    Kernel.update_in(req.headers, &Map.merge(&1, updates))
  end
end
