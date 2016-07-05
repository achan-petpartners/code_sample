Code.require_file "../scaffold_helper.exs", __DIR__

defmodule CodeSampleIntegrationTest do
  use ExUnit.Case

  setup do
    CodeSample.Authentication.start_link

    # Build up "./test/resources/pp_doc.txt" in a platform agnostic way
    test_file = Path.join [".", "test", "resources", "pp_doc.txt"]
    current_token = CodeSample.Authentication.get_token

    # If there is an exists version of this file, we want to delete it
    # We'll create a new version to run our tests against after this block
    # It is unusual that this file will actually exist, as it *normally* gets cleaned up by the on_exit callback
    case ScaffoldHelper.get_file_id("pp_doc.txt", current_token) do
      nil ->
        nil
      file_id ->
        ScaffoldHelper.delete_file!(file_id, current_token)
    end

    # Uploads a fresh copy of our example file.  pp_file_id will be passed into each test via the context map
    pp_file_id = ScaffoldHelper.upload_file!(test_file, current_token)

    # After each test finishes, we'll delete the file
    on_exit fn ->
      ScaffoldHelper.delete_file!(pp_file_id, current_token)
    end

    # Metadata to be passed to the tests
    {:ok, file_id: pp_file_id}
  end

  test "A fresh file has no comments", context do
    assert CodeSample.get_comments!(context[:file_id], CodeSample.Authentication.get_token) == nil
  end

  test "Getting comments from a non-existant file raises an exception" do
    assert_raise RuntimeError, fn ->
      CodeSample.get_comments!("1234", CodeSample.Authentication.get_token)
    end
  end


  test "adding a comment to a non-existant file raises an exception", context do
    assert_raise RuntimeError, fn ->
      CodeSample.add_comment!("1234", CodeSample.Authentication.get_token, "add comment")
    end
    assert Map.get(CodeSample.add_comment!(context[:file_id], CodeSample.Authentication.get_token, "test comment"), "message") == "test comment"
  end

  test "We can add a comment to a file", context do
    assert Map.get(CodeSample.add_comment!(context[:file_id], CodeSample.Authentication.get_token, "test comment"), "message") == "test comment"
  end


  test "Deleting a non-existant comment raises an exception" do
    assert_raise RuntimeError, fn ->
      CodeSample.delete_comment!("1234", CodeSample.Authentication.get_token)
    end
  end

  test "We can delete a comment from a file", context do
    response = CodeSample.add_comment!(context[:file_id], CodeSample.Authentication.get_token, "for delete")
    comment_id = Map.get(response, "id")
    assert CodeSample.delete_comment!(comment_id, CodeSample.Authentication.get_token) == 204  
  end

  test "Modifying a comment from a non-existant file raises an exception" do
    assert_raise RuntimeError, fn ->
      CodeSample.modify_comment!("1234", CodeSample.Authentication.get_token, "Modified a comment of a file.")
    end
  end

  test "We can modify a comment on a file", context do
    response = CodeSample.add_comment!(context[:file_id], CodeSample.Authentication.get_token, "for modify")
    comment_id = Map.get(response, "id")
    assert CodeSample.modify_comment!(comment_id, CodeSample.Authentication.get_token, "Modified a comment of a file.") == "Modified a comment of a file."
  end
end
