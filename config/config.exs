# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :drive_box,
  ecto_repos: [DriveBox.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the Repo
config :drive_box, DriveBox.Repo,
  migration_primary_key: [name: :id, type: :binary_id]

# Configures the endpoint
config :drive_box, DriveBoxWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DriveBoxWeb.ErrorHTML, json: DriveBoxWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: DriveBox.PubSub,
  live_view: [signing_salt: "xzeUIkGi"]

# Custom OAuth provider configurations
config :drive_box, :oauth_providers,
  google: [
    client_id: System.get_env("GOOGLE_CLIENT_ID") || "955773518680-9049vfcbo7dkl2qs877tqf0qdjcsj7nf.apps.googleusercontent.com",
    client_secret: System.get_env("GOOGLE_CLIENT_SECRET") || "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",
    strategy: Assent.Strategy.Google,
    redirect_uri: "http://localhost:3000/auth/google/callback",
    authorization_params: [
      access_type: "offline",
      scope: "email profile https://www.googleapis.com/auth/drive"
    ]
  ],
  github: [
    client_id: System.get_env("GITHUB_CLIENT_ID"),
    client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
    strategy: Assent.Strategy.Github,
    redirect_uri: "http://localhost:4000/auth/github/callback",
    scope: "user:email repo"
  ],
  dropbox: [
    client_id: System.get_env("DROPBOX_CLIENT_ID"),
    client_secret: System.get_env("DROPBOX_CLIENT_SECRET"),
    strategy: Assent.Strategy.OAuth2,
    base_url: "https://www.dropbox.com",
    authorize_url: "https://www.dropbox.com/oauth2/authorize",
    token_url: "https://api.dropbox.com/oauth2/token",
    user_url: "https://api.dropbox.com/2/users/get_current_account",
    authorization_params: [response_type: "code"],
    redirect_uri: "http://localhost:4000/auth/dropbox/callback",
    scope: "account_info.read files.metadata.read files.content.read files.content.write"
  ]

# JWT configuration for custom authentication
config :joken, default_signer: System.get_env("JWT_SECRET") || "your-secret-key"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :drive_box, DriveBox.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  drive_box: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  drive_box: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
