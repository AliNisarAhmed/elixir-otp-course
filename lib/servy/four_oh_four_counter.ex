defmodule Servy.FourOhFourCounter do
  @process_name __MODULE__

  def bump_count(route) do
    send(@process_name, {self(), :bump_count, route})

    receive do
      {:response, count} ->
        count
    end
  end

  def get_count(route) do
    send(@process_name, {self(), :get_count, route})

    receive do
      {:response, c} ->
        c
    end

  end

  def get_counts do
    send(@process_name, {self(), :get_counts})

    receive do
      {:response, counts} ->
        counts
    end

  end

  ## Server functions

  def listen_loop(state \\ %{}) do
    receive do
      {sender, :bump_count, route} ->
        state = Map.update(state, route, 1, fn v -> v + 1 end)
        send(sender, {:response, state[route]})
        listen_loop(state)

      {sender, :get_count, route} ->
        send(sender, {:response, state[route]})
        listen_loop(state)

      {sender, :get_counts} ->
        send(sender, {:response, state})
        listen_loop(state)

      _unexpected ->
        IO.puts("Unexpected")
        listen_loop(state)
    end
  end

  def start do
    IO.puts("Starting the 404 Counter server")
    pid = spawn(__MODULE__, :listen_loop, [%{}])
    Process.register(pid, @process_name)
    pid
  end
end
