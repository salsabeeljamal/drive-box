defmodule DriveBoxWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server, SecurityScheme}
  alias DriveBoxWeb.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        # Populate the Server info from a phoenix endpoint
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "DriveBox API",
        description: "API for managing files across Google Drive, GitHub, and Dropbox",
        version: "1.0.0"
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router),
      # Add authentication schemes
      components: %OpenApiSpex.Components{
        securitySchemes: %{
          "bearerAuth" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT",
            description: "Enter your bearer token"
          }
        }
      },
      security: [%{"bearerAuth" => []}]
    }
    # Discover request/response schemas from path specs
    |> OpenApiSpex.resolve_schema_modules()
  end
end 