defmodule TwitterFeed.Web.Plug.ReadinessProbe do
  @moduledoc false

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts) do
    %{
      path: Keyword.get(opts, :path, "/health/ready"),
      resp: Keyword.get(opts, :resp, "OK"),
      probe: Keyword.get(opts, :probe, &__MODULE__.probe/0)
    }
  end

  @impl true
  def call(%_{request_path: path} = conn, %{path: path, resp: resp, probe: probe}) do
    case probe.() do
      :ok ->
        conn
        |> send_resp(200, resp)
        |> halt()

      _ ->
        conn
    end
  end

  def call(conn, _opts), do: conn

  def probe, do: :ok
end
