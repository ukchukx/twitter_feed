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
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:extwitter, "~> 0.8"},
      {:oauther, "~> 1.1"},
      {:phoenix, "~> 1.4.9"},
      {:phoenix_live_view, "~> 0.3.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.14.3"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:logger_file_backend, "~> 0.0.10"},
      {:plug_cowboy, "~> 2.0"}
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
