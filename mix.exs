defmodule ConektaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :conekta_ex,
      version: "0.1.1",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Conekta API Client for Elixir",
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      applications: [:logger, :httpoison]
    ]
  end

  defp package do
    [
      name: "conekta_ex",
      maintainers: ["nysertxs"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/nysertxs/conekta_ex"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
