defmodule DriveBox.Users.UserIdentity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user_identities" do
    field :provider, :string
    field :uid, :string
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :connected_at, :utc_datetime
    field :raw_info, :map

    belongs_to :user, DriveBox.Users.User

    timestamps()
  end

  def changeset(user_identity, attrs) do
    user_identity
    |> cast(attrs, [:provider, :uid, :access_token, :refresh_token, :expires_at, :connected_at, :raw_info, :user_id])
    |> validate_required([:provider, :uid, :user_id])
    |> unique_constraint([:provider, :uid])
    |> unique_constraint([:provider, :user_id])
  end
end 