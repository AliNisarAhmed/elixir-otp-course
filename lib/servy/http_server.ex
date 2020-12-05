defmodule Servy.HttpServer do
  def server do
    {:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
    {:ok, sock} = :gen_tcp.accept(lsock)
    {:ok, bin} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    # ok = gen_tcp:close(LSock),
    bin
  end

  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    IO.puts("\n, listening for connection requests on port #{port}")

    accept_loop(listen_socket)
  end

  def accept_loop(listen_socket) do
    IO.puts "⏳ Waiting to accept client connection...\n"

    # suspends and waits for a client connection at this point. When a connection is
    # accepted, client_socket is bound to a new socket
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts("🌩 Connection accepted!\n")

    serve(client_socket)

    accept_loop(listen_socket)
  end

  # receievs requuest and sends the response back on the same socket
  def serve(client_socket) do
    client_socket
    |> read_request
    |> Servy.Handler.handle
    |> write_response(client_socket)
  end

  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    IO.puts "➡ Received request\n"
    IO.puts request

    request
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts(" Sent response\n")
    IO.puts(response)

    :gen_tcp.close(client_socket)
  end

  def send_request(request) do
    someHostInNet = 'localhost'

    {:ok, sock} = :gen_tcp.connect(someHostInNet, 4000, [:binary, packet: :raw, active: false])

    # request = """
    # GET /bears HTTP/1.1\r
    # Host: example.com\r
    # User-Agent: ExampleBrowser/1.0\r
    # Accept: */*\r
    # \r
    # """

    :ok = :gen_tcp.send(sock, request)

    {:ok, response} = :gen_tcp.recv(sock, 0)

    :ok = :gen_tcp.close(sock)

    response
  end

end
