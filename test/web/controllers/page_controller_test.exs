defmodule TwitterFeed.Web.PageControllerTest do
  use TwitterFeed.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "signin"
  end
end
