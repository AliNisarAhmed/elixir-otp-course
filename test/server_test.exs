defmodule ServerTest do
  use ExUnit.Case, async: true

  alias Servy.HttpServer

  test "Test our HttpServer in processes" do
     server_pid = spawn(HttpServer, :start, [4000])

    request1 = """
    GET /hibernate/2 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    request2 = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response1 = HttpServer.send_request(request1)

    response2 = HttpServer.send_request(request2)

    assert(is_binary(response2))
    assert(is_binary(response1))
  end

end
