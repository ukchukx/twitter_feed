defmodule TwitterFeed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      TwitterFeed.Repo,
      # Start the endpoint when the application starts
      TwitterFeed.Web.Endpoint
      # Starts a worker by calling: TwitterFeed.Worker.start_link(arg)
      # {TwitterFeed.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitterFeed.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, _} = res ->
        if Application.get_env(:twitter_feed, :env) != :test do
          Logger.info "Running migrations"
          path = Application.app_dir(:twitter_feed, "priv/repo/migrations")
          Ecto.Migrator.run(TwitterFeed.Repo, path, :up, all: true)
        end

        res

      {:error, _} = res ->
        res
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitterFeed.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
