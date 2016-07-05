defmodule CodeSample do
  
  @doc """
  Get comments for a given file_id.
  """
  @spec get_comments!(String.t, String.t) :: integer
  def get_comments!(file_id, token) do
    case HTTPoison.get! "https://api.box.com/2.0/files/#{file_id}/comments", %{Authorization: "Bearer #{token}"} do
      %{status_code: 200, body: body} ->
        body
        |> Poison.decode!
        |> Map.get("id")
      %{status_code: code, body: body} ->
        raise "Failed to get comments.  Received #{code}: #{body}"
    end
  end

  @doc """
  Adding comment for a given file_id 
  """
  def add_comment!(file_id, token, user_comment) do
    case HTTPoison.post! "https://api.box.com/2.0/comments", Poison.encode!(%{item: %{type: "file", id: "#{file_id}"}, message: "#{user_comment}"}), %{Authorization: "Bearer #{token}"}, [] do
      %{status_code: 201, body: body} ->  
        body
        |> Poison.decode!
      %{status_code: code, body: body} ->
        raise "Failed to add comments.  Received #{code}: #{body}"
    end
  end

  @doc """
  Deleting comment for a given file_id 
  """
  def delete_comment!(comment_id, token) do
    case HTTPoison.delete! "https://api.box.com/2.0/comments/#{comment_id}", %{Authorization: "Bearer #{token}"}, [] do
      %{status_code: 204} ->
        204
      %{status_code: code, body: body } ->
        raise "Failed to delete comments.  Received #{code}: #{body}"
    end
  end

  @doc """
  Modifying comment for a given file_id 
  """
   def modify_comment!(comment_id, token, comment) do
    case HTTPoison.put! "https://api.box.com/2.0/comments/#{comment_id}", Poison.encode!(%{message: "#{comment}"}), %{Authorization: "Bearer #{token}"}, [] do
      %{status_code: 200, body: body} ->
        body 
          |> Poison.decode!
          |> Map.get("message")
      %{status_code: code, body: body } ->
        raise "Failed to modify comments.  Received #{code}: #{body}"
    end
  end
end
