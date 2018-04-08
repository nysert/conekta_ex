defmodule ConektaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :conekta_ex,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Conekta API Client for Elixir",
      package: package()
    ]
  end

  def package do
    [
      name: "conekta_ex",
      maintainers: ["nysertxs"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/nysertxs/conekta_ex"}
    ]
  end

  def application do
    [
      applications: [:logger, :httpoison]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"}
    ]
  end
end
