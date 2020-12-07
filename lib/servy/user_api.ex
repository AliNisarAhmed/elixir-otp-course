defmodule Servy.UserAPI do
  def query(user_id) do
    route = "https://jsonplaceholder.typicode.com/users/#{user_id}"

    HTTPoison.get(route)
      |> handle_api_response
  end

  def handle_api_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body_map = Poison.Parser.parse!(body, %{})
    {:ok, get_in(body_map, ["address", "city"])}
  end

  def handle_api_response({:ok, %HTTPoison.Response{status_code: status, body: body}}) do
    body_map = Poison.Parser.parse!(body, %{})
    {:error, body_map["response"]}
  end

  def handle_api_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
