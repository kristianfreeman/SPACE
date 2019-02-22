defmodule SpaceWeb.PageController do
  use SpaceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
