defmodule HedwigQ.Mixfile do
  use Mix.Project

  def project do
    [app: :hedwig_q,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: [
       extras: ["README.md"]
     ],
     description: "A Q instant messenger adapter for Hedwig",
     source_url: "http://example.com/billc/hedwig_q",
     package: package
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :hedwig, :httpoison]]
  end

  defp deps do
    [
      {:hedwig, github: "hedwig-im/hedwig"},
      {:httpoison, "~> 0.9.2"},
      {:poison, "~> 2.0"},
      {:cowboy, "~> 1.0", optional: true},
      {:plug, "~> 1.2", optional: true},
      {:earmark, "~> 1.0", only: :dev },
      {:ex_doc, "~> 0.14.1", only: :dev },
      {:credo, "~> 0.4.12", only: :dev }

    ]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Bill Christian - bill.christian@gmail.com"],
     licenses: ["MIT"],
     links: %{
       "Github" => "stub",
     }]
  end
  
end
