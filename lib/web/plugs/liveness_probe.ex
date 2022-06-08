defmodule TwitterFeed.Web.Plug.LivenessProbe do
  @moduledoc false

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts) do
    %{
      path: Keyword.get(opts, :path, "/health/live"),
      resp: Keyword.get(opts, :resp, "OK")
    }
  end

  @impl true
  def call(%_{request_path: path} = conn, %{path: path, resp: resp}) do
    conn
    |> send_resp(200, resp)
    |> halt()
  end

  def call(conn, _opts), do: conn
end
