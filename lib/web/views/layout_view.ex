defmodule TwitterFeed.Web.LayoutView do
  use TwitterFeed.Web, :view

  def title(%{title: title}), do: title
  def title(_), do: ""

  def current_year(), do: DateTime.utc_now().year
end
