defmodule DriveBoxWeb.Plugs.AuthAPI do
  import Plug.Conn
  import Phoenix.Controller

  alias DriveBox.{Repo, Users.User}
  alias DriveBoxWeb.Auth.JWT

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{"user_id" => user_id}} <- JWT.verify_token(token),
         %User{} = user <- Repo.get(User, user_id) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        |> halt()
    end
  end
end 