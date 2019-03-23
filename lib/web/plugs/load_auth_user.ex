defmodule TwitterFeed.Web.Plug.LoadAuthUser do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && TwitterFeed.Accounts.get_user_by_id(user_id)
    assign(conn, :current_user, user)
  end

  @spec authenticate_user(Plug.Conn.t(), list()) :: Plug.Conn.t() | any()
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> redirect(to: TwitterFeed.Web.Router.Helpers.session_path(conn, :signin))
      |> halt
    end
  end
end
