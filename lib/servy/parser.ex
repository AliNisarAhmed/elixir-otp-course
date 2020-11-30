defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do

    [top, queryString] = String.split(request, "\n\n")

    params =
      queryString
        |> String.trim()
        |> URI.decode_query()

    [request_line | header_lines] = String.split(top, "\n")


    [method, path, _] =
      request_line
        |> String.split(" ")

    %Conv{
      method: method,
      path: path,
      params: params
    }
  end
end
