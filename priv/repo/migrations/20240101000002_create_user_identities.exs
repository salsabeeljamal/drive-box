defmodule DriveBox.Repo.Migrations.CreateUserIdentities do
  use Ecto.Migration

  def change do
    create table(:user_identities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string, null: false
      add :uid, :string, null: false
      add :access_token, :text
      add :refresh_token, :text
      add :expires_at, :utc_datetime
      add :raw_info, :map
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:user_identities, [:user_id, :provider])
    create index(:user_identities, [:provider])
    create index(:user_identities, [:uid])
  end
end 