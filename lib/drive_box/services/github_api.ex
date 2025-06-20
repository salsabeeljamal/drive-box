defmodule DriveBox.Services.GitHubAPI do
  @moduledoc """
  GitHub API client for repository and file operations
  """

  alias DriveBox.Users.UserIdentity
  alias DriveBox.Repo

  @base_url "https://api.github.com"

  def list_repositories(user_identity_id, opts \\ []) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      query_params = build_query_params(opts)
      url = "#{@base_url}/user/repos?#{query_params}"
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Accept", "application/vnd.github+json"},
        {"X-GitHub-Api-Version", "2022-11-28"}
      ]
      
      case HTTPoison.get(url, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def get_repository(user_identity_id, owner, repo) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/repos/#{owner}/#{repo}"
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Accept", "application/vnd.github+json"},
        {"X-GitHub-Api-Version", "2022-11-28"}
      ]
      
      case HTTPoison.get(url, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def list_repository_contents(user_identity_id, owner, repo, path \\ "") do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/repos/#{owner}/#{repo}/contents/#{path}"
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Accept", "application/vnd.github+json"},
        {"X-GitHub-Api-Version", "2022-11-28"}
      ]
      
      case HTTPoison.get(url, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def get_file_content(user_identity_id, owner, repo, path) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/repos/#{owner}/#{repo}/contents/#{path}"
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Accept", "application/vnd.github.raw"},
        {"X-GitHub-Api-Version", "2022-11-28"}
      ]
      
      case HTTPoison.get(url, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, body}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def create_file(user_identity_id, owner, repo, path, content, message, opts \\ []) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/repos/#{owner}/#{repo}/contents/#{path}"
      
      body = %{
        message: message,
        content: Base.encode64(content),
        branch: opts[:branch]
      } |> Enum.reject(fn {_, v} -> is_nil(v) end) |> Enum.into(%{})
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Accept", "application/vnd.github+json"},
        {"X-GitHub-Api-Version", "2022-11-28"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.put(url, Jason.encode!(body), headers) do
        {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
          {:ok, Jason.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          {:error, "API Error: #{status_code} - #{body}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP Error: #{reason}"}
      end
    end
  end

  def get_user_profile(user_identity_id) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      
      url = "#{@base_url}/user"
      
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Accept", "application/vnd.github+json"},
        {"X-GitHub-Api-Version", "2022-11-28"}
      ]
      
      case HTTPoison.get(url, headers) do
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
    # GitHub tokens don't expire, but implement refresh logic if needed
    {:ok, user_identity.access_token}
  end

  defp build_query_params(opts) do
    opts
    |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
    |> Enum.join("&")
  end
end 