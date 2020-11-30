defmodule Servy.FileHandler do

  alias Servy.Conv

  def handle_file({:ok, contents}, %Conv{} = conv) do
    %{conv | status: 200, resp_body: contents}
  end

  def handle_file({:error, :enoent}, %Conv{} = conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end

  def handle_file({:error, reason}, %Conv{} = conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end
end
