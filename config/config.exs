# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :twitter_feed, :topics,
  friends: "friends"

config :twitter_feed, :events,
  friend_added: [:friend, :added],
  tweet_marked: [:tweet, :marked]

config :twitter_feed,
  ecto_repos: [TwitterFeed.Repo]

config :twitter_feed, TwitterFeed.Repo,
  username: System.fetch_env!("TF_DB_USERNAME"),
  password: System.fetch_env!("TF_DB_PASSWORD"),
  hostname: "localhost"

config :extwitter, :oauth, [
    consumer_key: System.fetch_env!("TF_TWITTER_CONSUMER_KEY"),
    consumer_secret: System.fetch_env!("TF_TWITTER_CONSUMER_SECRET"),
    access_token: System.fetch_env!("TF_TWITTER_ACCESS_TOKEN"),
    access_token_secret: System.fetch_env!("TF_TWITTER_ACCESS_TOKEN_SECRET")
  ]


# Configures the endpoint
config :twitter_feed, TwitterFeed.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UhoTEvjsE1el9gL+Lhr2QEnQQady7LG+zGewDVQiEGVXLp4GmCvLqu+YBHBMziVQ",
  live_view: [signing_salt: "pR0CP5jlGrUiUbSvuDlxJVe50EYcZ9SwiuXRhoI1MaYdEkRnKXkGGsjgF6YBfLBe"],
  render_errors: [view: TwitterFeed.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TwitterFeed.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger,
  backends: [:console, {LoggerFileBackend, :file}],
  truncate: :infinity

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:all]

config :logger, :file,
  path: "logs/log.log",
  format: "[$date] [$time] [$level] $metadata $levelpad$message\n",
  metadata: [:all],
  level: :info,
  rotate: %{max_bytes: 2000000, keep: 5}

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
