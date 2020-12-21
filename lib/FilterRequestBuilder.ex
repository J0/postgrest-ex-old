defmodule FilterRequestBuilder do
  import Utils

  def filter(req, column, operator, criteria) do
    if req.negate_next do
      Map.update!(req, :negate_next, fn negate_next -> !negate_next end)
      operator = "not.#{operator}"
    end

    key = sanitize_params(column)
    val = "#{operator}.#{criteria}"

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
    values = Enum.map(fn param -> sanitize_params(param) end, values)
    values = Enum.join(values, ",")
  end

  def ov(req, column, values) do
    values = Enum.map(fn param -> sanitize_params(param) end, values)
    values = Enum.join(values, ",")
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
