defmodule DriveBoxWeb.AuthController do
  use DriveBoxWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Assent.HTTPAdapter.Req
  alias DriveBox.Repo
  alias DriveBox.Users.{User, UserIdentity}
  alias DriveBoxWeb.Auth.JWT
  alias DriveBoxWeb.Plugs.AuthSession
  alias DriveBoxWeb.Schemas
  import Ecto.Query

  tags ["Authentication"]

  def get_providers do
    Application.get_env(:drive_box, :oauth_providers, %{})
  end

  # API OAuth flow
  operation :authorize,
    summary: "Start OAuth authorization",
    tags: ["Authentication"],
    description: "Initiate OAuth authorization flow for a specific provider",
    parameters: [
      provider: [in: :path, description: "OAuth provider name", required: true, schema: %OpenApiSpex.Schema{type: :string, enum: ["google", "github", "dropbox"]}]
    ],
    responses: [
      ok: {"Authorization URL generated successfully", "application/json", Schemas.AuthorizeResponse},
      bad_request: {"Unsupported provider", "application/json", Schemas.Error},
      internal_server_error: {"Authorization failed", "application/json", Schemas.Error}
    ]

  def authorize(conn, %{"provider" => provider}) do
    case get_provider_config(provider) do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Unsupported provider"})

      config ->
        config = Keyword.put(config, :http_adapter, Req)
        
        case apply(config[:strategy], :authorize_url, [config]) do
          {:ok, %{url: url, session_params: session_params}} ->
            conn
            |> put_session(:oauth_state, session_params)
            |> put_session(:oauth_provider, provider)
            |> json(%{authorize_url: url})

          {:error, error} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Authorization failed: #{inspect(error)}"})
        end
    end
  end

  # Browser OAuth flow - redirect to provider
  def browser_authorize(conn, %{"provider" => provider}) do
    case get_provider_config(provider) do
      nil ->
        conn
        |> put_flash(:error, "Unsupported provider")
        |> redirect(to: "/login")

      config ->
        config = Keyword.put(config, :http_adapter, Req)
        
        case apply(config[:strategy], :authorize_url, [config]) do
          {:ok, %{url: url, session_params: session_params}} ->
            conn
            |> put_session(:oauth_state, session_params)
            |> put_session(:oauth_provider, provider)
            |> redirect(external: url)

          {:error, error} ->
            conn
            |> put_flash(:error, "Authorization failed: #{inspect(error)}")
            |> redirect(to: "/login")
        end
    end
  end

  # API OAuth callback
  operation :callback,
    summary: "OAuth callback endpoint",
    tags: ["Authentication"],
    description: "Handle OAuth callback from provider and complete authentication",
    parameters: [
      provider: [in: :path, description: "OAuth provider name", required: true, schema: %OpenApiSpex.Schema{type: :string, enum: ["google", "github", "dropbox"]}],
      code: [in: :query, description: "Authorization code from provider", type: :string, required: true],
      state: [in: :query, description: "State parameter for CSRF protection", type: :string, required: true]
    ],
    responses: [
      ok: {"Authentication successful", "application/json", Schemas.AuthenticationResponse},
      bad_request: {"Invalid state or provider mismatch", "application/json", Schemas.Error},
      internal_server_error: {"Authentication failed", "application/json", Schemas.Error}
    ]

  def callback(conn, %{"provider" => provider, "code" => code, "state" => state}) do
    case get_provider_config(provider) do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Unsupported provider"})

      config ->
        session_params = get_session(conn, :oauth_state)
        stored_provider = get_session(conn, :oauth_provider)

        if stored_provider == provider and session_params do
          config =
            config
            |> Keyword.put(:http_adapter, Req)
            |> Keyword.put(:session_params, session_params)

          # Prepare params for the callback
          callback_params = %{"code" => code, "state" => state}

          case apply(config[:strategy], :callback, [config, callback_params]) do
            {:ok, %{user: user_data, token: token_data}} ->
              IO.inspect(%{
                user_email: user_data["email"],
                user_name: user_data["name"],
                token_keys: Map.keys(token_data),
                has_access_token: !is_nil(token_data["access_token"])
              }, label: "✅ STRATEGY_SUCCESS")
              handle_api_auth_success(conn, provider, user_data, token_data)

            {:error, error} ->
              IO.inspect(%{
                error: error,
                error_type: error.__struct__ || "unknown",
                provider: provider,
                strategy: config[:strategy]
              }, label: "❌ STRATEGY_ERROR")
              conn
              |> put_status(:internal_server_error)
              |> json(%{error: "Authentication failed: #{inspect(error)}"})
          end
        else
          IO.inspect("Invalid state or provider mismatch", label: "❌ SESSION_MISMATCH")
          conn
          |> put_status(:bad_request)
          |> json(%{error: "Invalid state or provider mismatch"})
        end
    end
  end

  # Browser OAuth callback
  def browser_callback(conn, %{"provider" => provider, "code" => code, "state" => state}) do
    case get_provider_config(provider) do
      nil ->
        conn
        |> put_flash(:error, "Unsupported provider")
        |> redirect(to: "/login")

      config ->
        session_params = get_session(conn, :oauth_state)
        stored_provider = get_session(conn, :oauth_provider)

        if stored_provider == provider and session_params do
          config =
            config
            |> Keyword.put(:http_adapter, Req)
            |> Keyword.put(:session_params, session_params)

          # Prepare params for the callback
          callback_params = %{"code" => code, "state" => state}

          case apply(config[:strategy], :callback, [config, callback_params]) do
            {:ok, %{user: user_data, token: token_data}} ->
              handle_browser_auth_success(conn, provider, user_data, token_data)

            {:error, error} ->
              conn
              |> put_flash(:error, "Authentication failed: #{inspect(error)}")
              |> redirect(to: "/login")
          end
        else
          conn
          |> put_flash(:error, "Invalid state or provider mismatch")
          |> redirect(to: "/login")
        end
    end
  end

  operation :revoke,
    summary: "Disconnect OAuth provider",
    tags: ["Authentication"],
    description: "Disconnect a connected OAuth provider from the user's account",
    parameters: [
      provider: [in: :path, description: "OAuth provider name", required: true, schema: %OpenApiSpex.Schema{type: :string, enum: ["google", "github", "dropbox"]}]
    ],
    security: [%{"bearerAuth" => []}],
    responses: [
      ok: {"Provider disconnected successfully", "application/json", Schemas.SuccessMessage},
      not_found: {"Provider not connected", "application/json", Schemas.Error},
      internal_server_error: {"Failed to disconnect provider", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def revoke(conn, %{"provider" => provider}) do
    current_user = get_current_user(conn)
    
    case Repo.get_by(UserIdentity, user_id: current_user.id, provider: provider) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Provider not connected"})

      user_identity ->
        case Repo.delete(user_identity) do
          {:ok, _} ->
            conn
            |> json(%{message: "Provider disconnected successfully"})

          {:error, changeset} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to disconnect provider", details: changeset})
        end
    end
  end

  operation :connected_providers,
    summary: "List connected providers",
    tags: ["Authentication"],
    description: "Get a list of all OAuth providers connected to the user's account",
    security: [%{"bearerAuth" => []}],
    responses: [
      ok: {"Connected providers retrieved successfully", "application/json", Schemas.ConnectedProvidersResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def connected_providers(conn, _params) do
    current_user = get_current_user(conn)
    
    providers = 
      UserIdentity
      |> where(user_id: ^current_user.id)
      |> Repo.all()
      |> Enum.map(fn identity ->
        %{
          id: identity.id,
          provider: identity.provider,
          connected_at: identity.connected_at || identity.inserted_at,
          user_info: Map.get(identity.raw_info, "name") || Map.get(identity.raw_info, "login") || "Unknown"
        }
      end)

    conn
    |> json(%{providers: providers})
  end

  # Private functions
  defp get_provider_config(provider) do
    get_providers()[String.to_atom(provider)]
  end

  defp handle_api_auth_success(conn, provider, user_data, token_data) do
    case find_or_create_user(provider, user_data, token_data) do
      {:ok, {user, user_identity}} ->
        {:ok, jwt_token, _claims} = JWT.generate_token(user.id)
        
        conn
        |> json(%{
          message: "Authentication successful",
          user: %{
            id: user.id,
            email: user.email,
            name: user.name,
            avatar_url: user.avatar_url
          },
          provider: %{
            id: user_identity.id,
            provider: user_identity.provider,
            connected_at: user_identity.connected_at || user_identity.inserted_at
          },
          token: jwt_token
        })

      {:error, error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to create user: #{inspect(error)}"})
    end
  end

  defp handle_browser_auth_success(conn, provider, user_data, token_data) do
    IO.inspect(user_data, "user_data bug")
    case find_or_create_user(provider, user_data, token_data) do
      {:ok, {user, _user_identity}} ->
        conn
        |> AuthSession.login(user)
        |> put_flash(:info, "Successfully logged in with #{String.capitalize(provider)}")
        |> redirect(to: "/dashboard")

      {:error, error} ->
        conn
        |> put_flash(:error, "Failed to create user: #{inspect(error)}")
        |> redirect(to: "/login")
    end
  end

  defp find_or_create_user(provider, user_data, token_data) do
    email = get_user_email(user_data)
    name = get_user_name(user_data)
    avatar_url = get_user_avatar(user_data)
    uid = to_string(user_data["id"] || user_data["sub"])
    
    user_params = %{
      email: email,
      name: name,
      avatar_url: avatar_url
    }

    identity_params = %{
      provider: provider,
      uid: uid,
      access_token: token_data["access_token"],
      refresh_token: token_data["refresh_token"],
      expires_at: parse_expires_at(token_data["expires_in"]),
      connected_at: DateTime.utc_now(),
      raw_info: user_data
    }

    case Repo.get_by(UserIdentity, provider: provider, uid: uid) do
      nil ->
        # Create new user and identity
        create_user_with_identity(user_params, identity_params)

      identity ->
        # Update existing identity and return user
        case Repo.preload(identity, :user) do
          %{user: user} = identity ->
            case UserIdentity.changeset(identity, identity_params) |> Repo.update() do
              {:ok, updated_identity} -> {:ok, {user, updated_identity}}
              {:error, error} -> {:error, error}
            end
        end
    end
  end

  defp create_user_with_identity(user_params, identity_params) do
    Repo.transaction(fn ->
      case User.oauth_changeset(%User{}, user_params) |> Repo.insert() do
        {:ok, user} ->
          identity_params = Map.put(identity_params, :user_id, user.id)
          
          case UserIdentity.changeset(%UserIdentity{}, identity_params) |> Repo.insert() do
            {:ok, identity} -> {user, identity}
            {:error, error} -> Repo.rollback(error)
          end

        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  defp get_user_email(user_data) do
    user_data["email"] || user_data["primary_email"] || ""
  end

  defp get_user_name(user_data) do
    user_data["name"] || user_data["display_name"] || user_data["login"] || "Unknown"
  end

  defp get_user_avatar(user_data) do
    user_data["picture"] || user_data["avatar_url"] || user_data["profile_photo_url"]
  end

  defp parse_expires_at(nil), do: nil
  defp parse_expires_at(expires_in) when is_integer(expires_in) do
    DateTime.utc_now() |> DateTime.add(expires_in, :second)
  end
  defp parse_expires_at(expires_in) when is_binary(expires_in) do
    case Integer.parse(expires_in) do
      {seconds, _} -> parse_expires_at(seconds)
      :error -> nil
    end
  end

  defp get_current_user(conn) do
    token = get_req_header(conn, "authorization") |> List.first()
    
    if token do
      case JWT.verify_token(String.replace(token, "Bearer ", "")) do
        {:ok, %{"user_id" => user_id}} -> Repo.get(User, user_id)
        {:error, _} -> nil
      end
    else
      nil
    end
  end
end 