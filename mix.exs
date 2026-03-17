defmodule Inevitably.MixProject do
  use Mix.Project

  @project_name "Inevitably"
  @source_url "https://github.com/arcanemachine/inevitably"
  @version "0.1.0"

  def project do
    [
      app: :inevitably,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description:
        ~s(Inevitably provides an ergonomic "eventually" do...end macro for ExUnit tests.),
      package: package(),

      # Docs
      name: @project_name,
      source_url: @source_url
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
      files: ~w(.formatter.exs LICENSE README.md mix.exs lib),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp deps do
    []
  end
end
