defmodule DriveBox.Services.GoogleDriveAPI do
  @moduledoc """
  Google Drive API client for file operations
  """

  alias DriveBox.Users.UserIdentity
  alias DriveBox.Repo

  @base_url "https://www.googleapis.com/drive/v3"
  @upload_url "https://www.googleapis.com/upload/drive/v3"

  def list_files(user_identity_id, opts \\ []) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      headers = [
        Authorization: "Bearer #{access_token}",
        "Content-Type": "application/json"
      ]

      case Req.get(@base_url <> "/files", params: opts, headers: headers) do
        {:ok, %{status: 200, body: body}} ->
          {:ok, body}
        {:ok, %{status: status, body: body}} ->
          {:error, "API Error: #{status} - #{inspect(body)}"}
        {:error, reason} ->
          {:error, "HTTP Error: #{inspect(reason)}"}
      end
    end
  end

  def get_file(user_identity_id, file_id) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      headers = [
        Authorization: "Bearer #{access_token}",
        "Content-Type": "application/json"
      ]

      case Req.get(@base_url <> "/files/" <> file_id, headers: headers) do
        {:ok, %{status: 200, body: body}} ->
          {:ok, body}
        {:ok, %{status: status, body: body}} ->
          {:error, "API Error: #{status} - #{inspect(body)}"}
        {:error, reason} ->
          {:error, "HTTP Error: #{inspect(reason)}"}
      end
    end
  end

  def download_file(user_identity_id, file_id) do
    with {:ok, %{"mimeType" => mime_type}} <- get_file(user_identity_id, file_id) do
      cond do
        is_google_doc?(mime_type) ->
          export_google_doc(user_identity_id, file_id, mime_type)

        true ->
          download_binary_file(user_identity_id, file_id)
      end
    end
  end

  def upload_file(user_identity_id, file_name, file_content, opts \\ []) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      metadata =
        %{
          name: file_name,
          parents: opts[:parents]
        }
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> Enum.into(%{})

      boundary = "----boundary#{System.unique_integer([:positive])}"
      body = build_multipart_body(metadata, file_content, boundary)

      headers = [
        Authorization: "Bearer #{access_token}",
        "Content-Type": "multipart/related; boundary=#{boundary}"
      ]

      case Req.post(@upload_url <> "/files",
             body: body,
             params: [uploadType: "multipart"],
             headers: headers
           ) do
        {:ok, %{status: 200, body: body}} ->
          {:ok, body}
        {:ok, %{status: status, body: body}} ->
          {:error, "API Error: #{status} - #{inspect(body)}"}
        {:error, reason} ->
          {:error, "HTTP Error: #{inspect(reason)}"}
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
    # This would involve calling Google's token refresh endpoint
    {:ok, user_identity.access_token}
  end

  defp download_binary_file(user_identity_id, file_id) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      headers = [
        Authorization: "Bearer #{access_token}"
      ]

      case Req.get(@base_url <> "/files/" <> file_id, params: [alt: "media"], headers: headers) do
        {:ok, %{status: 200, body: body}} ->
          {:ok, body}
        {:ok, %{status: status, body: body}} ->
          {:error, "API Error: #{status} - #{inspect(body)}"}
        {:error, reason} ->
          {:error, "HTTP Error: #{inspect(reason)}"}
      end
    end
  end

  defp export_google_doc(user_identity_id, file_id, mime_type) do
    with {:ok, user_identity} <- get_user_identity(user_identity_id),
         {:ok, access_token} <- get_valid_access_token(user_identity) do
      export_mime_type = get_export_mime_type(mime_type)

      headers = [
        Authorization: "Bearer #{access_token}"
      ]

      case Req.get(@base_url <> "/files/" <> file_id <> "/export",
             params: [mimeType: export_mime_type],
             headers: headers
           ) do
        {:ok, %{status: 200, body: body}} ->
          {:ok, body}
        {:ok, %{status: status, body: body}} ->
          {:error, "API Error: #{status} - #{inspect(body)}"}
        {:error, reason} ->
          {:error, "HTTP Error: #{inspect(reason)}"}
      end
    end
  end

  defp is_google_doc?(mime_type) do
    String.starts_with?(mime_type, "application/vnd.google-apps")
  end

  defp get_export_mime_type("application/vnd.google-apps.document"),
    do: "application/pdf"

  defp get_export_mime_type("application/vnd.google-apps.spreadsheet"),
    do: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  defp get_export_mime_type("application/vnd.google-apps.presentation"),
    do: "application/vnd.openxmlformats-officedocument.presentationml.presentation"

  defp get_export_mime_type(_),
    do: "application/pdf" # Default export format

  defp build_multipart_body(metadata, file_content, boundary) do
    """
    --#{boundary}
    Content-Type: application/json

    #{Jason.encode!(metadata)}
    --#{boundary}
    Content-Type: application/octet-stream

    #{file_content}
    --#{boundary}--
    """
  end
end 