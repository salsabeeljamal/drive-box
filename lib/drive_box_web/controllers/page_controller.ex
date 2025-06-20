defmodule DriveBoxWeb.PageController do
  use DriveBoxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
