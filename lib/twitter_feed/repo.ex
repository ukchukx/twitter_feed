defmodule TwitterFeed.Repo do
  use Ecto.Repo,
    otp_app: :twitter_feed,
    adapter: Ecto.Adapters.Postgres
end
