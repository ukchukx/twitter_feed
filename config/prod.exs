use Mix.Config

config :twitter_feed, env: :prod

port =
  case System.fetch_env!("TF_PORT") do
    x when is_integer(x) -> x
    x -> x |> Integer.parse |> elem(0)
  end

config :twitter_feed, TwitterFeed.Web.Endpoint,
  http: [:inet6, port: port],
  url: [host: "twitterfeed.moview.com.ng", port: 443, scheme: "https"],
  check_origin: false,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :logger,
  compile_time_purge_matching: [
    [application: :twitter_feed, level_lower_than: :info]
  ]
# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :twitter_feed, TwitterFeed.Web.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         :inet6,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :twitter_feed, TwitterFeed.Web.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases (distillery)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :twitter_feed, TwitterFeed.Web.Endpoint, server: true
#
# Note you can't rely on `System.get_env/1` when using releases.
# See the releases documentation accordingly.
config :twitter_feed, TwitterFeed.Web.Endpoint,
  secret_key_base: "TFbFo1gq4ik+Xp1gvmH+u7eJFB71yD2MoA6ITUVxCVduK3RfxMBg+Sso4xn+DjVd"

# Configure your database
config :twitter_feed, TwitterFeed.Repo,
  database: "twitter_feed",
  pool_size: 15
