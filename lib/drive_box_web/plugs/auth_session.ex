defmodule DriveBoxWeb.Plugs.AuthSession do
  import Plug.Conn
  import Phoenix.Controller

  alias DriveBox.{Repo, Users.User}

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      case Repo.get(User, user_id) do
        %User{} = user ->
          assign(conn, :current_user, user)
        nil ->
          conn
          |> clear_session()
          |> assign(:current_user, nil)
      end
    else
      assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> assign(:current_user, user)
  end

  def logout(conn) do
    conn
    |> clear_session()
    |> assign(:current_user, nil)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end 