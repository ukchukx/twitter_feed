defmodule TwitterFeed.Web.PageController do
  use TwitterFeed.Web, :controller

  def index(%{assigns: %{current_user: user = %{id: _}}} = conn, _) do
    %{friends: friends} = TwitterFeed.Accounts.load_friends(user)

    render conn, "index.html",
      user: user,
      title: "Friends",
      friends: friends
  end

  def index(conn, _), do: redirect(conn, to: Routes.session_path(conn, :signin))

  def catch_all(conn, _), do: redirect(conn, to: Routes.page_path(conn, :index))
end
