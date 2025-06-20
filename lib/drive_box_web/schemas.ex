defmodule DriveBoxWeb.Schemas do
  alias OpenApiSpex.Schema

  defmodule User do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "User",
      description: "A user of the application",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "User ID", format: :uuid},
        email: %Schema{type: :string, description: "User email", format: :email},
        name: %Schema{type: :string, description: "User name"},
        avatar_url: %Schema{type: :string, description: "User avatar URL", format: :uri},
        active: %Schema{type: :boolean, description: "Whether user is active"},
        inserted_at: %Schema{type: :string, description: "Creation timestamp", format: :"date-time"},
        updated_at: %Schema{type: :string, description: "Update timestamp", format: :"date-time"}
      },
      required: [:id, :email],
      example: %{
        "id" => "123e4567-e89b-12d3-a456-426614174000",
        "email" => "user@example.com",
        "name" => "John Doe",
        "avatar_url" => "https://example.com/avatar.jpg",
        "active" => true,
        "inserted_at" => "2024-01-01T00:00:00Z",
        "updated_at" => "2024-01-01T00:00:00Z"
      }
    })
  end

  defmodule Error do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "Error",
      description: "Error response",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "Error message"},
        details: %Schema{type: :string, description: "Detailed error information"}
      },
      required: [:error],
      example: %{
        "error" => "Not found",
        "details" => "The requested resource was not found"
      }
    })
  end

  defmodule FileInfo do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "FileInfo",
      description: "File information from cloud storage",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "File ID"},
        name: %Schema{type: :string, description: "File name"},
        size: %Schema{type: :integer, description: "File size in bytes"},
        mime_type: %Schema{type: :string, description: "MIME type"},
        modified_time: %Schema{type: :string, description: "Last modified time", format: :"date-time"},
        download_url: %Schema{type: :string, description: "Download URL", format: :uri},
        provider: %Schema{type: :string, description: "Storage provider", enum: ["google", "github", "dropbox"]}
      },
      required: [:id, :name, :provider],
      example: %{
        "id" => "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms",
        "name" => "example.txt",
        "size" => 1024,
        "mime_type" => "text/plain",
        "modified_time" => "2024-01-01T00:00:00Z",
        "download_url" => "https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms",
        "provider" => "google"
      }
    })
  end

  defmodule Repository do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "Repository",
      description: "GitHub repository information",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Repository ID"},
        name: %Schema{type: :string, description: "Repository name"},
        full_name: %Schema{type: :string, description: "Full repository name"},
        description: %Schema{type: :string, description: "Repository description"},
        private: %Schema{type: :boolean, description: "Whether repository is private"},
        html_url: %Schema{type: :string, description: "Repository URL", format: :uri},
        language: %Schema{type: :string, description: "Primary language"},
        stargazers_count: %Schema{type: :integer, description: "Number of stars"},
        forks_count: %Schema{type: :integer, description: "Number of forks"}
      },
      required: [:id, :name, :full_name],
      example: %{
        "id" => 123456789,
        "name" => "my-repo",
        "full_name" => "user/my-repo",
        "description" => "A sample repository",
        "private" => false,
        "html_url" => "https://github.com/user/my-repo",
        "language" => "Elixir",
        "stargazers_count" => 42,
        "forks_count" => 7
      }
    })
  end

  defmodule DropboxAccount do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "DropboxAccount",
      description: "Dropbox account information",
      type: :object,
      properties: %{
        account_id: %Schema{type: :string, description: "Account ID"},
        name: %Schema{
          type: :object,
          properties: %{
            given_name: %Schema{type: :string, description: "First name"},
            surname: %Schema{type: :string, description: "Last name"},
            display_name: %Schema{type: :string, description: "Display name"}
          }
        },
        email: %Schema{type: :string, description: "Email address", format: :email},
        email_verified: %Schema{type: :boolean, description: "Whether email is verified"},
        profile_photo_url: %Schema{type: :string, description: "Profile photo URL", format: :uri}
      },
      required: [:account_id, :email],
      example: %{
        "account_id" => "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc",
        "name" => %{
          "given_name" => "John",
          "surname" => "Doe",
          "display_name" => "John Doe"
        },
        "email" => "john@example.com",
        "email_verified" => true,
        "profile_photo_url" => "https://dl-web.dropbox.com/account_photo/get/dbaphid%3AAAHWGmIXV3sUuOmBfTz0wPsiqHUpBWvv3ZA?vers=1556069330102&size=128x128"
      }
    })
  end

  defmodule GitHubContent do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "GitHubContent",
      description: "GitHub repository content item",
      type: :object,
      properties: %{
        name: %Schema{type: :string, description: "File or directory name"},
        path: %Schema{type: :string, description: "Full path"},
        type: %Schema{type: :string, description: "Content type", enum: ["file", "dir"]},
        size: %Schema{type: :integer, description: "File size in bytes"},
        download_url: %Schema{type: :string, description: "Download URL", format: :uri},
        html_url: %Schema{type: :string, description: "GitHub URL", format: :uri}
      },
      required: [:name, :path, :type],
      example: %{
        "name" => "README.md",
        "path" => "README.md",
        "type" => "file",
        "size" => 1024,
        "download_url" => "https://raw.githubusercontent.com/user/repo/main/README.md",
        "html_url" => "https://github.com/user/repo/blob/main/README.md"
      }
    })
  end

  defmodule GitHubProfile do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "GitHubProfile", 
      description: "GitHub user profile information",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "User ID"},
        login: %Schema{type: :string, description: "Username"},
        name: %Schema{type: :string, description: "Display name"},
        email: %Schema{type: :string, description: "Email address", format: :email},
        avatar_url: %Schema{type: :string, description: "Avatar URL", format: :uri},
        html_url: %Schema{type: :string, description: "Profile URL", format: :uri},
        public_repos: %Schema{type: :integer, description: "Number of public repositories"},
        followers: %Schema{type: :integer, description: "Number of followers"},
        following: %Schema{type: :integer, description: "Number of following"}
      },
      required: [:id, :login],
      example: %{
        "id" => 123456,
        "login" => "octocat",
        "name" => "The Octocat",
        "email" => "octocat@github.com",
        "avatar_url" => "https://github.com/images/error/octocat_happy.gif",
        "html_url" => "https://github.com/octocat",
        "public_repos" => 8,
        "followers" => 20,
        "following" => 0
      }
    })
  end

  defmodule AuthorizeResponse do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "AuthorizeResponse",
      description: "OAuth authorization response",
      type: :object,
      properties: %{
        authorize_url: %Schema{type: :string, description: "OAuth authorization URL", format: :uri}
      },
      required: [:authorize_url],
      example: %{
        "authorize_url" => "https://accounts.google.com/o/oauth2/auth?client_id=..."
      }
    })
  end

  defmodule AuthenticationResponse do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "AuthenticationResponse",
      description: "Successful authentication response",
      type: :object,
      properties: %{
        message: %Schema{type: :string, description: "Success message"},
        user: User,
        provider: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :string, description: "Provider identity ID"},
            provider: %Schema{type: :string, description: "Provider name"},
            connected_at: %Schema{type: :string, description: "Connection timestamp (last callback time)", format: :"date-time"}
          }
        },
        token: %Schema{type: :string, description: "JWT authentication token"}
      },
      required: [:message, :user, :provider, :token],
      example: %{
        "message" => "Authentication successful",
        "user" => %{
          "id" => "123e4567-e89b-12d3-a456-426614174000",
          "email" => "user@example.com",
          "name" => "John Doe",
          "avatar_url" => "https://example.com/avatar.jpg"
        },
        "provider" => %{
          "id" => "provider-123",
          "provider" => "google",
          "connected_at" => "2024-01-01T00:00:00Z"
        },
        "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      }
    })
  end

  defmodule ConnectedProvider do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "ConnectedProvider",
      description: "Information about a connected OAuth provider",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "Provider identity ID"},
        provider: %Schema{type: :string, description: "Provider name", enum: ["google", "github", "dropbox"]},
        connected_at: %Schema{type: :string, description: "Connection timestamp", format: :"date-time"},
        user_info: %Schema{type: :string, description: "User information from provider"}
      },
      required: [:id, :provider, :connected_at, :user_info],
      example: %{
        "id" => "provider-123",
        "provider" => "google",
        "connected_at" => "2024-01-01T00:00:00Z",
        "user_info" => "John Doe"
      }
    })
  end

  defmodule ConnectedProvidersResponse do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "ConnectedProvidersResponse",
      description: "List of connected OAuth providers",
      type: :object,
      properties: %{
        providers: %Schema{type: :array, items: ConnectedProvider}
      },
      required: [:providers],
      example: %{
        "providers" => [
          %{
            "id" => "provider-123",
            "provider" => "google",
            "connected_at" => "2024-01-01T00:00:00Z",
            "user_info" => "John Doe"
          }
        ]
      }
    })
  end

  defmodule SuccessMessage do
    require OpenApiSpex
    OpenApiSpex.schema(%{
      title: "SuccessMessage",
      description: "Success message response",
      type: :object,
      properties: %{
        message: %Schema{type: :string, description: "Success message"}
      },
      required: [:message],
      example: %{
        "message" => "Provider disconnected successfully"
      }
    })
  end
end 