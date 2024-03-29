defmodule TwitterFeed.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :twitter_feed

  @session_options [
    store: :cookie,
    key: "_twitter_feed_key",
    signing_salt: "4Y5eDiaN"
  ]

  socket "/socket", TwitterFeed.Web.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Handle health checks
  plug TwitterFeed.Web.Plug.LivenessProbe
  plug TwitterFeed.Web.Plug.ReadinessProbe
  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :twitter_feed,
    gzip: false,
    only: ~w(css fonts webfonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session, @session_options

  plug TwitterFeed.Web.Router
end
