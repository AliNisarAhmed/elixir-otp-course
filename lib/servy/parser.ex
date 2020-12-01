defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, queryString] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], queryString)

    [method, path, _] =
      request_line
      |> String.split(" ")

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_params("application/x-www-form-urlencoded", query_string) do
    query_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

  def parse_headers(header_lines) do
    header_lines
    |> Enum.reduce(%{}, fn x, acc ->
      [key, value] = String.split(x, ": ")
      Map.put(acc, key, value)
    end)
  end
end
