defmodule TwitterFeed.Web.PageController do
  use TwitterFeed.Web, :controller


  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec friend(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @spec catch_all(Plug.Conn.t(), map()) :: Plug.Conn.t()

  def index(%{assigns: %{current_user: user = %{id: _}}} = conn, _) do
    render conn, "index.html", user: user, title: "Friends"
  end

  def index(conn, _), do: redirect(conn, to: Routes.session_path(conn, :signin))

  def friend(%{assigns: %{current_user: user = %{id: _}}} = conn, %{"id" => id}) do
    friend = TwitterFeed.Accounts.get_user_by_id(id)

    render conn, "show.html",
      user: user,
      title: friend.name,
      friend: friend
  end

  def catch_all(conn, _), do: redirect(conn, to: Routes.page_path(conn, :index))
end
