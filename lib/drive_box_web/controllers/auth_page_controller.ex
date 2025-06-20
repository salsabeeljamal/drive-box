defmodule DriveBoxWeb.AuthPageController do
  use DriveBoxWeb, :controller
  import Ecto.Query

  alias DriveBoxWeb.Plugs.AuthSession

  def login(conn, _params) do
    conn
    |> put_layout(html: {DriveBoxWeb.Layouts, :root})
    |> render(:login)
  end

  def dashboard(conn, _params) do
    current_user = conn.assigns[:current_user]
    
    if current_user do
      user_identities = DriveBox.Repo.all(
        from ui in DriveBox.Users.UserIdentity,
        where: ui.user_id == ^current_user.id
      )
      
      conn
      |> put_layout(html: {DriveBoxWeb.Layouts, :root})
      |> render(:dashboard, user: current_user, user_identities: user_identities)
    else
      conn
      |> redirect(to: "/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> AuthSession.logout()
    |> put_flash(:info, "Successfully logged out")
    |> redirect(to: "/login")
  end
end 