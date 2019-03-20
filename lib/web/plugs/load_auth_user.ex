defmodule TwitterFeed.Web.Plug.LoadAuthUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && TwitterFeed.Accounts.get_user_by_id(user_id)
    assign(conn, :current_user, user)
  end
end
