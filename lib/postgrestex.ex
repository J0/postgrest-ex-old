defmodule Postgrestex do
  @moduledoc """
  Documentation for `Postgrestex`.
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
    if username != nil do
      Map.merge(
        req,
        %{options: [hackney: [basic_auth: {username, password}]]}
      )
    else
      Map.put(
        req,
        :headers,
        Map.merge(req.headers, %{Authorization: "Bearer #{token}"})
      )
    end
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
    options = Map.get(req, :options, [])

    case req.method do
      "POST" -> HTTPoison.post!(url, body, headers, params: params, options: options)
      "GET" -> HTTPoison.get!(url, headers, options: options)
      "PATCH" -> HTTPoison.patch!(url, %{}, headers, params: params, options: options)
      "DELETE" -> HTTPoison.delete!(url, params: params, options: options)
      _ -> IO.puts("Method not found!")
    end
  end

  def select(req, columns) do
    Map.put(
      req,
      :headers,
      Map.merge(req.headers, %{select: Enum.join(columns, ","), method: "GET"})
    )
  end

  def insert(req, json, upsert \\ False) do
    prefer_option = if upsert, do: ",resolution=merge-duplicates", else: ""
    headers = Map.merge(req.headers, %{Prefer: prefer_option, method: "POST"})
    req |> Map.merge(headers) |> Map.merge(%{body: json})
  end

  def update(req, json) do
    updated_headers = Map.merge(req.headers, %{Prefer: "return=representation"})

    updated_headers
    |> Map.merge(%{method: "PATCH", body: json})
    |> Map.merge(req)
  end

  def delete(req, json) do
    req |> Map.merge(%{method: "DELETE", body: json})
  end

  def order(req, column, desc \\ False, nullsfirst \\ False) do
    desc = if desc, do: ".desc", else: ""
    nullsfirst = if nullsfirst, do: ".nullsfirst", else: ""
    headers = Map.merge(req.headers, %{order: "#{column} #{desc} #{nullsfirst}"})
    req |> Map.merge(headers)
  end

  def limit(req, size, start) do
    Map.merge(req.headers, %{Range: "#{start}-#{start + size - 1}", "Range-Unit": "items"})
    |> Map.merge(req)
  end

  def range(req, start, end_) do
    updated_headers =
      Map.merge(req.headers, %{Range: "#{start}-#{end_ - 1}", "Range-Unit": "items"})

    updated_headers |> Map.merge(req)
  end

  def single(req) do
    # Modify this to use a session header
    Map.merge(req.headers, %{Accept: "application/vnd.pgrst.object+json"})
  end

  def sanitize_params(str) do
    reserved_chars = String.graphemes(",.:()")
    if String.contains?(str, reserved_chars), do: str, else: "#{str}"
  end

  def sanitize_pattern_params(str) do
    str |> String.replace("%", "*")
  end

  def filter(req, column, operator, criteria) do
    {req, operator} =
      if req.negate_next do
        {Map.update!(req, :negate_next, fn negate_next -> !negate_next end), "not.#{operator}"}
      end

    val = "#{operator}.#{criteria}"
    key = sanitize_params(column)

    req =
      if Map.has_key?(req.params, key),
        do: Map.update(req.params, key, fn params -> params ++ [val] end),
        else: Kernel.put_in(req, [:params, key], val)

    Map.merge(req, %{method: "POST"})
  end

  def not req do
    Map.merge(req, %{negate_next: True})
  end

  def eq(req, column, value) do
    filter(req, column, "eq", sanitize_params(value))
  end

  def neq(req, column, value) do
    filter(req, column, "neq", sanitize_params(value))
  end

  def gt(req, column, value) do
    filter(req, column, "gt", sanitize_params(value))
  end

  def lt(req, column, value) do
    filter(req, column, "lt", sanitize_params(value))
  end

  def lte(req, column, value) do
    filter(req, column, "lte", sanitize_params(value))
  end

  def is_(req, column, value) do
    filter(req, column, "is", sanitize_params(value))
  end

  def like(req, column, pattern) do
    filter(req, column, "like", sanitize_pattern_params(pattern))
  end

  def ilike(req, column, pattern) do
    filter(req, column, "is", sanitize_params(pattern))
  end

  def fts(req, column, query) do
    filter(req, column, "fts", sanitize_params(query))
  end

  def plfts(req, column, query) do
    filter(req, column, "plfts", sanitize_params(query))
  end

  def phfts(req, column, query) do
    filter(req, column, "phfts", sanitize_params(query))
  end

  def wfts(req, column, query) do
    filter(req, column, "wfts", sanitize_params(query))
  end

  def in_(req, column, values) do
    values = Enum.map(fn param -> sanitize_params(param) end, values)
    values = Enum.join(values, ",")
    filter(req, column, "in", "(#{values})")
  end

  def cs(req, column, values) do
    values = Enum.map(fn param -> sanitize_params(param) end, values)
    values = Enum.join(values, ",")
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

  def sl(req, column, range) do
    filter(req, column, "sl", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  def sr(req, column, range) do
    filter(req, column, "sr", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  def nxl(req, column, range) do
    filter(req, column, "nxl", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  def nxr(req, column, range) do
    filter(req, column, "nxr", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end

  def adj(req, column, range) do
    filter(req, column, "adj", "(#{Enum.at(range, 0)},#{Enum.at(range, 1)})")
  end
end
