use Mix.Config

config :twitter_feed, env: :test
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :twitter_feed, TwitterFeed.Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :twitter_feed, TwitterFeed.Repo,
  username: System.get_env("TF_DB_USERNAME"),
  password: System.get_env("TF_DB_PASSWORD"),
  database: "twitter_feed_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
