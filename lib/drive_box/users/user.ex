defmodule DriveBox.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :name, :string
    field :avatar_url, :string
    field :active, :boolean, default: true
    field :password_hash, :string, virtual: true

    has_many :user_identities, DriveBox.Users.UserIdentity

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [:email, :name, :avatar_url, :active])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def oauth_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> cast(attrs, [:email, :name, :avatar_url, :active])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end 