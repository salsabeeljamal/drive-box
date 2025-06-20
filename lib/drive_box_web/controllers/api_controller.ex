defmodule DriveBoxWeb.APIController do
  use DriveBoxWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias DriveBox.Services.{GoogleDriveAPI, GitHubAPI, DropboxAPI}
  alias DriveBox.{Repo, Users.UserIdentity}
  alias DriveBox.Users.User
  alias DriveBoxWeb.Schemas

  tags ["Google Drive", "GitHub", "Dropbox"]

  # Google Drive endpoints
  
  operation :google_files,
    summary: "List Google Drive files",
    tags: ["Google Drive"],
    description: "Retrieve a list of files from the user's Google Drive",
    parameters: [
      limit: [in: :query, description: "Maximum number of files to return", type: :integer, example: 10],
      offset: [in: :query, description: "Number of files to skip", type: :integer, example: 0],
      sort: [in: :query, description: "Sort field", type: :string, example: "name"],
      order: [in: :query, description: "Sort order", type: :string, example: "asc"]
    ],
    responses: [
      ok: {"Files retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          files: %OpenApiSpex.Schema{type: :array, items: Schemas.FileInfo}
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def google_files(conn, params) do
    with {:ok, user_identity} <- get_user_identity(conn, "google") do
      opts = build_list_options(params)
      
      case GoogleDriveAPI.list_files(user_identity.id, opts) do
        {:ok, files_response} ->
          conn |> json(files_response)
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :google_file,
    summary: "Get Google Drive file details",
    tags: ["Google Drive"],
    description: "Retrieve details of a specific file from Google Drive",
    parameters: [
      file_id: [in: :path, description: "Google Drive file ID", type: :string, required: true]
    ],
    responses: [
      ok: {"File details retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          file: Schemas.FileInfo
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def google_file(conn, %{"file_id" => file_id}) do
    with {:ok, user_identity} <- get_user_identity(conn, "google") do
      case GoogleDriveAPI.get_file(user_identity.id, file_id) do
        {:ok, file} ->
          conn |> json(%{file: file})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :google_download,
    summary: "Download Google Drive file",
    tags: ["Google Drive"],
    description: "Download a file from Google Drive",
    parameters: [
      file_id: [in: :path, description: "Google Drive file ID", type: :string, required: true]
    ],
    responses: [
      ok: {"File downloaded successfully", "application/octet-stream", %OpenApiSpex.Schema{type: :string, format: :binary}},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def google_download(conn, %{"file_id" => file_id}) do
    with {:ok, user_identity} <- get_user_identity(conn, "google") do
      case GoogleDriveAPI.download_file(user_identity.id, file_id) do
        {:ok, content} ->
          conn
          |> put_resp_content_type("application/octet-stream")
          |> send_resp(200, content)
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :google_upload,
    summary: "Upload file to Google Drive",
    tags: ["Google Drive"],
    description: "Upload a file to Google Drive",
    request_body: {"File upload", "multipart/form-data", %OpenApiSpex.Schema{
      type: :object,
      properties: %{
        file: %OpenApiSpex.Schema{type: :string, format: :binary, description: "File to upload"},
        parents: %OpenApiSpex.Schema{type: :array, items: %OpenApiSpex.Schema{type: :string}, description: "Parent folder IDs"},
        description: %OpenApiSpex.Schema{type: :string, description: "File description"}
      },
      required: [:file]
    }},
    responses: [
      ok: {"File uploaded successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          file: Schemas.FileInfo,
          message: %OpenApiSpex.Schema{type: :string}
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def google_upload(conn, %{"file" => %Plug.Upload{} = upload} = params) do
    with {:ok, user_identity} <- get_user_identity(conn, "google") do
      file_content = File.read!(upload.path)
      opts = build_upload_options(params)
      
      case GoogleDriveAPI.upload_file(user_identity.id, upload.filename, file_content, opts) do
        {:ok, file} ->
          conn |> json(%{file: file, message: "File uploaded successfully"})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  # GitHub endpoints
  operation :github_repositories,
    summary: "List GitHub repositories",
    tags: ["GitHub"],
    description: "Retrieve a list of repositories from the user's GitHub account",
    parameters: [
      limit: [in: :query, description: "Maximum number of repositories to return", type: :integer, example: 10],
      offset: [in: :query, description: "Number of repositories to skip", type: :integer, example: 0]
    ],
    responses: [
      ok: {"Repositories retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          repositories: %OpenApiSpex.Schema{type: :array, items: Schemas.Repository}
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def github_repositories(conn, params) do
    with {:ok, user_identity} <- get_user_identity(conn, "github") do
      opts = build_list_options(params)
      
      case GitHubAPI.list_repositories(user_identity.id, opts) do
        {:ok, repos} ->
          conn |> json(%{repositories: repos})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :github_repository,
    summary: "Get GitHub repository details",
    tags: ["GitHub"],
    description: "Retrieve details of a specific GitHub repository",
    parameters: [
      owner: [in: :path, description: "Repository owner", type: :string, required: true],
      repo: [in: :path, description: "Repository name", type: :string, required: true]
    ],
    responses: [
      ok: {"Repository details retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          repository: Schemas.Repository
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def github_repository(conn, %{"owner" => owner, "repo" => repo}) do
    with {:ok, user_identity} <- get_user_identity(conn, "github") do
      case GitHubAPI.get_repository(user_identity.id, owner, repo) do
        {:ok, repository} ->
          conn |> json(%{repository: repository})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :github_contents,
    summary: "List GitHub repository contents",
    tags: ["GitHub"],
    description: "Retrieve contents of a GitHub repository directory",
    parameters: [
      owner: [in: :path, description: "Repository owner", type: :string, required: true],
      repo: [in: :path, description: "Repository name", type: :string, required: true],
      path: [in: :query, description: "Directory path", type: :string]
    ],
    responses: [
      ok: {"Repository contents retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          contents: %OpenApiSpex.Schema{type: :array, items: Schemas.GitHubContent}
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def github_contents(conn, %{"owner" => owner, "repo" => repo} = params) do
    with {:ok, user_identity} <- get_user_identity(conn, "github") do
      path = params["path"] || ""
      
      case GitHubAPI.list_repository_contents(user_identity.id, owner, repo, path) do
        {:ok, contents} ->
          conn |> json(%{contents: contents})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :github_file_content,
    summary: "Get GitHub file content",
    tags: ["GitHub"],
    description: "Retrieve the content of a specific file from a GitHub repository",
    parameters: [
      owner: [in: :path, description: "Repository owner", type: :string, required: true],
      repo: [in: :path, description: "Repository name", type: :string, required: true],
      path: [in: :path, description: "File path", type: :string, required: true]
    ],
    responses: [
      ok: {"File content retrieved successfully", "text/plain", %OpenApiSpex.Schema{type: :string}},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def github_file_content(conn, %{"owner" => owner, "repo" => repo, "path" => path}) do
    with {:ok, user_identity} <- get_user_identity(conn, "github") do
      case GitHubAPI.get_file_content(user_identity.id, owner, repo, path) do
        {:ok, content} ->
          conn
          |> put_resp_content_type("text/plain")
          |> send_resp(200, content)
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :github_create_file,
    summary: "Create file in GitHub repository",
    tags: ["GitHub"],
    description: "Create a new file in a GitHub repository",
    parameters: [
      owner: [in: :path, description: "Repository owner", type: :string, required: true],
      repo: [in: :path, description: "Repository name", type: :string, required: true],
      path: [in: :path, description: "File path", type: :string, required: true]
    ],
    request_body: {"File creation data", "application/json", %OpenApiSpex.Schema{
      type: :object,
      properties: %{
        content: %OpenApiSpex.Schema{type: :string, description: "File content (base64 encoded)"},
        message: %OpenApiSpex.Schema{type: :string, description: "Commit message"},
        branch: %OpenApiSpex.Schema{type: :string, description: "Branch name"},
        committer: %OpenApiSpex.Schema{
          type: :object,
          properties: %{
            name: %OpenApiSpex.Schema{type: :string},
            email: %OpenApiSpex.Schema{type: :string, format: :email}
          }
        }
      },
      required: [:content, :message]
    }},
    responses: [
      ok: {"File created successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          file: Schemas.GitHubContent,
          message: %OpenApiSpex.Schema{type: :string}
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def github_create_file(conn, %{"owner" => owner, "repo" => repo, "path" => path, "content" => content, "message" => message} = params) do
    with {:ok, user_identity} <- get_user_identity(conn, "github") do
      opts = build_github_create_options(params)
      
      case GitHubAPI.create_file(user_identity.id, owner, repo, path, content, message, opts) do
        {:ok, file} ->
          conn |> json(%{file: file, message: "File created successfully"})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :github_profile,
    summary: "Get GitHub user profile",
    tags: ["GitHub"],
    description: "Retrieve the authenticated user's GitHub profile information",
    responses: [
      ok: {"Profile retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          profile: Schemas.GitHubProfile
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def github_profile(conn, _params) do
    with {:ok, user_identity} <- get_user_identity(conn, "github") do
      case GitHubAPI.get_user_profile(user_identity.id) do
        {:ok, profile} ->
          conn |> json(%{profile: profile})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  # Dropbox endpoints
  operation :dropbox_files,
    summary: "List Dropbox files",
    tags: ["Dropbox"],
    description: "Retrieve a list of files from the user's Dropbox",
    parameters: [
      path: [in: :query, description: "Folder path", type: :string],
      recursive: [in: :query, description: "Include subdirectories", type: :boolean],
      include_media_info: [in: :query, description: "Include media info", type: :boolean],
      include_deleted: [in: :query, description: "Include deleted files", type: :boolean]
    ],
    responses: [
      ok: {"Files retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          files: %OpenApiSpex.Schema{type: :array, items: Schemas.FileInfo}
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def dropbox_files(conn, params) do
    with {:ok, user_identity} <- get_user_identity(conn, "dropbox") do
      path = params["path"] || ""
      opts = build_dropbox_list_options(params)
      
      case DropboxAPI.list_files(user_identity.id, path, opts) do
        {:ok, files} ->
          conn |> json(%{files: files})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :dropbox_file_metadata,
    summary: "Get Dropbox file metadata",
    tags: ["Dropbox"],
    description: "Retrieve metadata for a specific file in Dropbox",
    parameters: [
      path: [in: :query, description: "File path", type: :string, required: true]
    ],
    responses: [
      ok: {"File metadata retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          metadata: Schemas.FileInfo
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def dropbox_file_metadata(conn, %{"path" => path}) do
    with {:ok, user_identity} <- get_user_identity(conn, "dropbox") do
      case DropboxAPI.get_file_metadata(user_identity.id, path) do
        {:ok, metadata} ->
          conn |> json(%{metadata: metadata})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  def dropbox_download(conn, %{"path" => path}) do
    with {:ok, user_identity} <- get_user_identity(conn, "dropbox") do
      case DropboxAPI.download_file(user_identity.id, path) do
        {:ok, content} ->
          conn
          |> put_resp_content_type("application/octet-stream")
          |> send_resp(200, content)
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :dropbox_upload,
    summary: "Upload file to Dropbox",
    tags: ["Dropbox"],
    description: "Upload a file to Dropbox",
    parameters: [
      path: [in: :query, description: "Upload path", type: :string, required: true]
    ],
    request_body: {"File upload", "multipart/form-data", %OpenApiSpex.Schema{
      type: :object,
      properties: %{
        file: %OpenApiSpex.Schema{type: :string, format: :binary, description: "File to upload"},
        mode: %OpenApiSpex.Schema{type: :string, description: "Upload mode", enum: ["add", "overwrite", "update"]},
        autorename: %OpenApiSpex.Schema{type: :boolean, description: "Auto rename if conflict"}
      },
      required: [:file]
    }},
    responses: [
      ok: {"File uploaded successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          file: Schemas.FileInfo,
          message: %OpenApiSpex.Schema{type: :string}
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def dropbox_upload(conn, %{"path" => path, "file" => %Plug.Upload{} = upload} = params) do
    with {:ok, user_identity} <- get_user_identity(conn, "dropbox") do
      file_content = File.read!(upload.path)
      opts = build_dropbox_upload_options(params)
      
      case DropboxAPI.upload_file(user_identity.id, path, file_content, opts) do
        {:ok, file} ->
          conn |> json(%{file: file, message: "File uploaded successfully"})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  def dropbox_create_folder(conn, %{"path" => path} = params) do
    with {:ok, user_identity} <- get_user_identity(conn, "dropbox") do
      opts = build_dropbox_folder_options(params)
      
      case DropboxAPI.create_folder(user_identity.id, path, opts) do
        {:ok, folder} ->
          conn |> json(%{folder: folder, message: "Folder created successfully"})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  def dropbox_delete(conn, %{"path" => path}) do
    with {:ok, user_identity} <- get_user_identity(conn, "dropbox") do
      case DropboxAPI.delete_file(user_identity.id, path) do
        {:ok, result} ->
          conn |> json(%{result: result, message: "File deleted successfully"})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  operation :dropbox_account_info,
    summary: "Get Dropbox account information",
    tags: ["Dropbox"],
    description: "Retrieve account information from the user's Dropbox account",
    responses: [
      ok: {"Account info retrieved successfully", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          account_info: Schemas.DropboxAccount
        }
      }},
      bad_request: {"Error response", "application/json", Schemas.Error},
      unauthorized: {"Authentication required", "application/json", Schemas.Error}
    ]

  def dropbox_account_info(conn, _params) do
    with {:ok, user_identity} <- get_user_identity(conn, "dropbox") do
      case DropboxAPI.get_account_info(user_identity.id) do
        {:ok, account_info} ->
          conn |> json(%{account_info: account_info})
        
        {:error, error} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: error})
      end
    end
  end

  # Helper functions
  defp get_user_identity(conn, provider) do
    current_user = get_current_user(conn)
    
    if current_user do
      case Repo.get_by(UserIdentity, user_id: current_user.id, provider: provider) do
        nil ->
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "#{String.capitalize(provider)} not connected"})
          |> halt()

        user_identity ->
          {:ok, user_identity}
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Authentication required"})
      |> halt()
    end
  end

  defp get_current_user(conn) do
    conn.assigns[:current_user]
  end

  defp build_list_options(params) do
    params
    |> Map.take(["limit", "offset", "sort", "order"])
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp build_upload_options(params) do
    params
    |> Map.take(["parents", "description"])
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp build_github_create_options(params) do
    params
    |> Map.take(["branch", "committer", "author"])
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp build_dropbox_list_options(params) do
    params
    |> Map.take(["recursive", "include_media_info", "include_deleted", "include_has_explicit_shared_members"])
    |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_existing_atom(v)} end)
  end

  defp build_dropbox_upload_options(params) do
    params
    |> Map.take(["mode", "autorename", "mute", "strict_conflict"])
    |> Enum.map(fn 
      {"mode", v} -> {:mode, v}
      {k, v} -> {String.to_atom(k), String.to_existing_atom(v)}
    end)
  end

  defp build_dropbox_folder_options(params) do
    params
    |> Map.take(["autorename"])
    |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_existing_atom(v)} end)
  end

  defp find_or_create_user(provider, user_data, token_data) do
    # Extract user info from OAuth provider data
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
end 