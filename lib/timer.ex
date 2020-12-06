defmodule Servy.Timer do
  def remind(s, seconds) do
    spawn(fn ->
      :timer.sleep(seconds * 1000)
      IO.puts(s)
    end)
  end
end
