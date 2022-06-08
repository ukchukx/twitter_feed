use Mix.Config

config :twitter_feed, env: :prod

config :twitter_feed, TwitterFeed.Web.Endpoint,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :logger,
  compile_time_purge_matching: [
    [application: :twitter_feed, level_lower_than: :info]
  ]

# Configure your database
config :twitter_feed, TwitterFeed.Repo,
  database: "twitter_feed",
  pool_size: 15
