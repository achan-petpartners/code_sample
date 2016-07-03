defmodule CodeSample do
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

  def add_comment!(file_id, token, user_comment) do
    case HTTPoison.post! "https://api.box.com/2.0/comments", Poison.encode!(%{item: %{type: "file", id: "#{file_id}"}, message: "#{user_comment}"}), %{Authorization: "Bearer #{token}"}, [] do
        %{status_code: 201, body: body} ->
        
        body
        |> Poison.decode!
        #|> Map.get("message")
      %{status_code: code, body: body} ->
        raise "Failed to add comments.  Received #{code}: #{body}"
    end
  end

  def delete_comment!(file_id, token) do
    response = add_comment!(file_id, token, "for delete")
    comment_id = Map.get(response, "id")
    IO.puts "should get printed #{comment_id}"
    #case get_comments!(response, token) do
    #  %{status_code: 201, body: body} -> IO.puts body
    case HTTPoison.delete! "https://api.box.com/2.0/comments/#{comment_id}", %{Authorization: "Bearer #{token}"}, [] do
      %{status_code: 204} ->
       204
       %{status_code: code, body: body } ->
        raise "Failed to delete comments.  Received #{code}: #{body}"
    end
  end

   def modify_comment!(file_id, token, comment) do
    response = add_comment!(file_id, token, "for modify")
    comment_id = Map.get(response, "id")
    IO.puts "should get printed #{comment_id}"
    #case get_comments!(response, token) do
    #  %{status_code: 201, body: body} -> IO.puts body
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
