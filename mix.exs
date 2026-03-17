defmodule Inevitably.MixProject do
  use Mix.Project

  @project_name "Inevitably"
  @source_url "https://github.com/arcanemachine/inevitably"
  @version "0.1.0"

  def project do
    [
      app: :inevitably,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description:
        ~s(Inevitably provides an ergonomic "eventually" do...end macro for ExUnit tests.),
      package: package(),

      # Docs
      name: @project_name,
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: :inevitably,
      files: ~w(.formatter.exs CHANGELOG.md LICENSE README.md mix.exs lib),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md": [title: "README"],
        "CHANGELOG.md": [title: "Changelog"]
      ],
      formatters: ["html"]
    ]
  end
end
