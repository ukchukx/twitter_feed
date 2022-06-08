defmodule TwitterFeed.Repo do
  use Ecto.Repo,
    otp_app: :twitter_feed,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    {:ok, Confex.Resolver.resolve!(config)}
  end
end
