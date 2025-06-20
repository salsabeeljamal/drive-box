defmodule DriveBox.Repo.Migrations.AddConnectedAtToUserIdentities do
  use Ecto.Migration

  def change do
    alter table(:user_identities) do
      add :connected_at, :utc_datetime
    end
    
    # Set existing records' connected_at to their inserted_at
    execute "UPDATE user_identities SET connected_at = inserted_at WHERE connected_at IS NULL"
  end
end 