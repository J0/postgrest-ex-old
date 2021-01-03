defmodule Postgrestex.MixProject do
  use Mix.Project

  def project do
    [
      app: :postgrestex,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Postgrestex",
      source_url: "https://github.com/j0/postgrestex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "This is a elixir client library for PostgREST, built with the intention of supporting Supabase"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "postgrestex",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*  LICENSE*
                 ),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/j0/postgrestex"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.2"},

      # Dev dependencies
      {:ex_doc, "~> 0.13", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
