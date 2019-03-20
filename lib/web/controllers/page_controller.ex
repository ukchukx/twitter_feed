defmodule TwitterFeed.Web.PageController do
  use TwitterFeed.Web, :controller

  def index(%{assigns: %{current_user: %{id: _}}} = conn, _params) do
    render conn, "index.html"
  end

  def index(conn, _), do: redirect(conn, to: Routes.session_path(conn, :signin))

  def catch_all(conn, _), do: redirect(conn, to: Routes.page_path(conn, :index))
end
