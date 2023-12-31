defmodule ExCrawlzy.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_crawlzy,
      version: "0.1.1",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExCrawlzy",
      description: "Another crawler for Elixir inspired on Tesla.",
      source_url: "https://github.com/nicolkill/ex_crawlzy",
      package: package(),
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:jason, ">= 1.0.0"},
      {:floki, "~> 0.34.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
      name: "ex_crawlzy",
      files: ~w(lib priv config .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nicolkill/ex_crawlzy"}
    ]
  end
end
