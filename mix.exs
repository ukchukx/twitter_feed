defmodule TwitterFeed.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitter_feed,
      version: "2.0.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: debug_info(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TwitterFeed.Application, []},
      extra_applications: [:logger, :runtime_tools, :extwitter]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp debug_info(:prod), do: [debug_info: false]
  defp debug_info(_), do: [debug_info: true]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:confex, "~> 3.4.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:extwitter, "~> 0.13"},
      {:floki, ">= 0.30.0", only: :test},
      {:oauther, "~> 1.1"},
      {:phoenix, "~> 1.6.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4.0"},
      {:ecto_sql, "~> 3.3"},
      {:postgrex, ">= 0.14.3"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      # {:poison, "~> 3.1"},
      {:plug_cowboy, "~> 2.1"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
