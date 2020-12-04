defmodule Servy.Api.BearController do
  def index(conv) do
    json =
      Servy.Wildthings.list_bears()

    conv = put_resp_content_type(conv, "application/json")

    %{
      conv
      | status: 200,
        resp_body: json
    }
  end

  def create(conv, %{"name" => name, "type" => type }) do
    json = Poison.encode!("Created a #{type} bear named #{name}!")

    conv = put_resp_content_type(conv, "application/json")

    %{ conv | status: 201, resp_body: json}
  end

  defp put_resp_content_type(conv, value) do
    new_resp_headers = Map.put(conv.resp_headers, "Content-Type", value)
    %{conv | resp_headers: new_resp_headers}
  end
end
