# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :twitter_feed, :topics,
  friends: "friends",
  friend: "friend"

config :twitter_feed, :events,
  friend_added: ~w[friend added]a,
  friend_updated: ~w[friend updated]a,
  friend_removed: ~w[friend removed]a,
  tweet_marked: ~w[tweet marked]a

config :twitter_feed,
  ecto_repos: [TwitterFeed.Repo]

config :twitter_feed, TwitterFeed.Repo,
  username: {:system, "TF_DB_USER", ""},
  password: {:system, "TF_DB_PASS", ""},
  hostname: {:system, "TF_DB_HOST", "localhost"},
  database: {:system, "TF_DB_NAME", "twitter_feed"},
  pool_size: 10

config :extwitter, :oauth,
  consumer_key: {:system, "TF_TWITTER_CONSUMER_KEY", ""},
  consumer_secret: {:system, "TF_TWITTER_CONSUMER_SECRET", ""},
  access_token: {:system, "TF_TWITTER_ACCESS_TOKEN", ""},
  access_token_secret: {:system, "TF_TWITTER_ACCESS_TOKEN_SECRET", ""}

config :twitter_feed, TwitterFeed.Web.Endpoint,
  url: [
    host: {:system, "TF_HOSTNAME", "localhost"},
    scheme: {:system, "TF_SCHEME", "http"},
    port: {:system, :integer, "TF_URL_PORT", 4000}
  ],
  http: [:inet6, port: 4000],
  check_origin: false,
  secret_key_base: {:system, "TF_SECRET_KEY_BASE", "dummy"},
  live_view: [signing_salt: "NruUhNTU7kIdLaFROePJiWn8X1HrH/3G"],
  render_errors: [view: TwitterFeed.Web.ErrorView, accepts: ~w(html json)],
  pubsub_server: TwitterFeed.PubSub

config :logger,
  utc_log: true,
  truncate: :infinity

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:all]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
