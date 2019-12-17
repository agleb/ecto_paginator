defmodule EctoPaginator.Mixfile do
  use Mix.Project

  @version "0.6.0"

  def project do
    [
      app: :ecto_paginator,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: description(),
      package: package(),

      # Docs
      name: "ecto_paginator",
      source_url: "https://github.com/agleb/ecto_paginator",
      homepage_url: "https://github.com/agleb/ecto_paginator",
      docs: [
        source_ref: "v#{@version}",
        main: "ecto_paginator",
        canonical: "http://hexdocs.pm/ecto_paginator",
        source_url: "https://github.com/agleb/ecto_paginator"
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:calendar, "~> 0.17.4", only: :test},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:ex_machina, "~> 2.1", only: :test},
      {:inch_ex, "~> 1.0", only: [:dev, :test]},
      {:postgrex, "~> 0.13", optional: true}
    ]
  end

  defp description do
    """
    Cursor based pagination for Elixir Ecto.
    """
  end

  defp package do
    [
      maintainers: ["Gleb Andreev"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/agleb/ecto_paginator"}
    ]
  end
end
