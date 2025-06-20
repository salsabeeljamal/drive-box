defmodule DriveBox.Repo do
  use Ecto.Repo,
    otp_app: :drive_box,
    adapter: Ecto.Adapters.Postgres
end 