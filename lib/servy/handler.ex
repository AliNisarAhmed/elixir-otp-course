defmodule Servy.Handler do
  @moduledoc """
  Handles Http Requests
  """

  @pages_path Path.expand("pages", File.cwd!())

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

  @doc """
  Transforms the request into a response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    # |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/snapshots" } = conv) do

    parent = self() # the request-handling process, the one that runs the handler function

    spawn(fn -> send(parent, VideoCam.get_snapshot("cam-1")) end)
    spawn(fn -> send(parent, VideoCam.get_snapshot("cam-2")) end)
    spawn(fn -> send(parent, VideoCam.get_snapshot("cam-3")) end)

    snapshot1 = receive do {:result, filename} -> filename end
    snapshot2 = receive do {:result, filename } -> filename end
    snapshot3 = receive do {:result, filename } -> filename end

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status: 200, resp_body: inspect snapshots}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Awake!" }
  end
  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    file =
      @pages_path
      |> Path.join("about.html")

    case File.read(file) do
      {:ok, contents} ->
        %{conv | status: 200, resp_body: contents}

      {:error, :enoent} ->
        %{conv | status: 404, resp_body: "File not found"}

      {:error, reason} ->
        %{conv | status: 500, resp_body: "File error: #{reason}"}
    end
  end

  # alternate way to do the above code, instead of case expressions

  def route(%Conv{method: "GET", path: "/contact"} = conv) do
    @pages_path
    |> Path.join("contact.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    @pages_path
    |> Path.join("faq.md")
    |> File.read()
    |> handle_file(conv)
    |> markdown_to_html()

  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{} = conv) do
    %{conv | resp_body: "No #{conv.path} here", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv.resp_headers)}
    \r
    #{conv.resp_body}
    """
  end

  def put_content_length(%{resp_body: resp_body} = conv) do
    new_resp_headers = Map.put(conv, "Content-Length", String.length(resp_body))
    %{conv | resp_headers: new_resp_headers}
  end

  def format_response_headers(conv) do
    conv.resp_headers
    |> Enum.map(fn {k, v} -> "#{k}: #{v}\r" end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")

    # for {key, value} <- conv.resp_headers do
    #   "#{key}: #{value}\r"
    # end
    # |> Enum.sort()
    # |> Enum.reverse()
    # |> Enum.join("\n")
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    %{conv | resp_body: Earmark.as_html!(conv.resp_body)}
  end

  def markdown_to_html(conv), do: conv
end
