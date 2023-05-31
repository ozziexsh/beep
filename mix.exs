defmodule Beep.MixProject do
  use Mix.Project

  def project do
    [
      app: :beep,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Add common repo functionality into an ecto schema module directly",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/ozziexsh/beep"}
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29.4"}
    ]
  end
end
