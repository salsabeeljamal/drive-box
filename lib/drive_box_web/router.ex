defmodule DriveBoxWeb.Router do
  use DriveBoxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DriveBoxWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DriveBoxWeb.Plugs.AuthSession
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug OpenApiSpex.Plug.PutApiSpec, module: DriveBoxWeb.ApiSpec
  end

  pipeline :protected_api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug OpenApiSpex.Plug.PutApiSpec, module: DriveBoxWeb.ApiSpec
    plug DriveBoxWeb.Plugs.AuthAPI
  end

  pipeline :protected_api_download do
    plug :fetch_session
    plug DriveBoxWeb.Plugs.AuthAPI
  end

  scope "/", DriveBoxWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", AuthPageController, :login
    get "/dashboard", AuthPageController, :dashboard
    get "/logout", AuthPageController, :logout
  end

  # API Documentation routes
  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/" do
    pipe_through :browser
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  # Custom API authentication routes
  scope "/api/auth", DriveBoxWeb do
    pipe_through :api
    
    # OAuth provider connection for API clients
    get "/:provider/authorize", AuthController, :authorize
    get "/:provider/callback", AuthController, :callback
    delete "/:provider", AuthController, :revoke
    
    # Get connected providers
    get "/", AuthController, :connected_providers
  end

  # Browser OAuth routes
  scope "/auth", DriveBoxWeb do
    pipe_through :browser
    
    get "/:provider", AuthController, :browser_authorize
    get "/:provider/callback", AuthController, :browser_callback
  end

  # Protected API routes
  scope "/api", DriveBoxWeb do
    pipe_through :protected_api

    # Google Drive API
    scope "/google" do
      get "/files", APIController, :google_files
      get "/files/:file_id", APIController, :google_file
      post "/files/upload", APIController, :google_upload
      post "/files/bulk_download", APIController, :google_bulk_download
    end

    # GitHub API
    scope "/github" do
      get "/repositories", APIController, :github_repositories
      get "/repositories/:owner/:repo", APIController, :github_repository
      get "/repositories/:owner/:repo/contents", APIController, :github_contents
      get "/repositories/:owner/:repo/contents/*path", APIController, :github_file_content
      post "/repositories/:owner/:repo/contents/*path", APIController, :github_create_file
      get "/profile", APIController, :github_profile
    end

    # Dropbox API
    scope "/dropbox" do
      get "/files", APIController, :dropbox_files
      get "/files/metadata", APIController, :dropbox_file_metadata
      post "/files/upload", APIController, :dropbox_upload
      post "/files/create_folder", APIController, :dropbox_create_folder
      delete "/files", APIController, :dropbox_delete
      get "/account", APIController, :dropbox_account_info
      post "/files/bulk_download", APIController, :dropbox_bulk_download
    end
  end

  # Protected API download routes
  scope "/api", DriveBoxWeb do
    pipe_through :protected_api_download

    scope "/google" do
      get "/files/:file_id/download", APIController, :google_download
    end

    scope "/dropbox" do
      get "/files/download", APIController, :dropbox_download
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:drive_box, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DriveBoxWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
