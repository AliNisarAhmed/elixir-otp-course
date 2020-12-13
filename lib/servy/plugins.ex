defmodule Servy.Plugins do

  require Logger

  alias Servy.Conv
  alias Servy.FourOhFourCounter


  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect(conv)
    end
    conv
  end

  def rerwite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning, #{path} is on the loose!")
      Logger.info("Tracking with Logger")
      Logger.warn("This is a warning")
      Logger.error("This is an error")

      FourOhFourCounter.bump_count(path)
    end
    conv
  end

  def track(%Conv{} = conv), do: conv


end
