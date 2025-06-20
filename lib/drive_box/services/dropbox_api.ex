defmodule DriveBox.Services.DropboxAPI do
  @moduledoc """
  Dropbox API client for file operations
  """

  alias DriveBox.Users.UserIdentity
  alias DriveBox.Repo

  @base_url "https://api.dropboxapi.com/2"
  @content_url "https://content.dropboxapi.com/2"

  def list_files(user_identity_id, path \\ "", opts \\ []) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/files/list_folder"
      
      body = %{
        path: path,
        recursive: opts[:recursive] || false,
        include_media_info: opts[:include_media_info] || false,
        include_deleted: opts[:include_deleted] || false,
        include_has_explicit_shared_members: opts[:include_has_explicit_shared_members] || false
      }
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.post(url, Jason.encode!(body), headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def get_file_metadata(user_identity_id, path) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/files/get_metadata"
      
      body = %{
        path: path,
        include_media_info: false,
        include_deleted: false,
        include_has_explicit_shared_members: false
      }
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.post(url, Jason.encode!(body), headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def download_file(user_identity_id, path) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@content_url}/files/download"
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Dropbox-API-Arg", Jason.encode!(%{path: path})}
      ]
      
      case HTTPoison.post(url, "", headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, body}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def upload_file(user_identity_id, path, file_content, opts \\ []) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@content_url}/files/upload"
      
      upload_args = %{
        path: path,
        mode: opts[:mode] || "add",
        autorename: opts[:autorename] || false,
        mute: opts[:mute] || false,
        strict_conflict: opts[:strict_conflict] || false
      }
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Dropbox-API-Arg", Jason.encode!(upload_args)},
        {"Content-Type", "application/octet-stream"}
      ]
      
      case HTTPoison.post(url, file_content, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def create_folder(user_identity_id, path, opts \\ []) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/files/create_folder_v2"
      
      body = %{
        path: path,
        autorename: opts[:autorename] || false
      }
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.post(url, Jason.encode!(body), headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def delete_file(user_identity_id, path) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/files/delete_v2"
      
      body = %{path: path}
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.post(url, Jason.encode!(body), headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def get_account_info(user_identity_id) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/users/get_current_account"
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.post(url, "null", headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  defp get_user_identity(user_identity_id) do
    case Repo.get(UserIdentity, user_identity_id) do
      nil -> {:error, "User identity not found"}
      user_identity -> {:ok, user_identity}
    end
  end

  defp get_valid_access_token(user_identity) do
    if token_expired?(user_identity) do
      refresh_access_token(user_identity)
    else
      {:ok, user_identity.access_token}
    end
  end

  defp token_expired?(user_identity) do
    case user_identity.expires_at do
      nil -> false
      expires_at -> DateTime.compare(DateTime.utc_now(), expires_at) == :gt
    end
  end

  defp refresh_access_token(user_identity) do
    # Implement token refresh logic here
    # This would involve calling Dropbox's token refresh endpoint
    {:ok, user_identity.access_token}
  end
end 