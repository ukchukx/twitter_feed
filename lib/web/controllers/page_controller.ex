defmodule TwitterFeed.Web.PageController do
  use TwitterFeed.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
