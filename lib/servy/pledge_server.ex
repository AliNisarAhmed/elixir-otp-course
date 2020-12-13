defmodule Servy.PledgeServer do

  @process_name :pledge_server
  @url "https://httparrot.herokuapp.com/post"

  # Client facing functions
  def start do
    IO.puts "Starting the pledge server"
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @process_name)
    pid
  end

  def create_pledge(name, amount) do

    #Cache the pledge:
    send(@process_name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} ->
        status
    end
  end

  def recent_pledges() do
    send(@process_name, {self(), :recent_pledges})

    receive do
      {:response, pledges} ->
        pledges
    end

  end

  def total_pledged() do
    send(@process_name, {self(), :total_pledged})

    receive do
      {:response, total} ->
        total
    end

  end

  # Server functions
  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent = Enum.take(state, 2)
        new_state = [ {name, amount} | most_recent ]
        send(sender, {:response, id})
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send(sender, { :response, state })
        IO.puts("send pledges to #{inspect sender}")
        listen_loop(state)
      {sender, :total_pledged} ->
        sum =
          state
            |> Enum.map(fn {_ , amount} -> amount end)
            |> Enum.sum()
        send(sender, {:response, sum })
        listen_loop(state)
      # unexpected ->
      #   IO.puts "Unexpected message #{inspect unexpected}"
      #   listen_loop(state)
    end

  end

  defp send_pledge_to_service(name, amount) do
    # {:ok, "pledge-#{:rand.uniform(1000)}"}
    body = ~s({"name" : "#{name}", "amount": "#{amount}", "id": "#{:rand.uniform(1000)}" })
    headers = ~s({"Content-Type": "application/json"})
    {:ok, response} = HTTPoison.post(@url, body, headers)
    body = Poison.Parser.parse!(response.body, %{})
    {:ok, body["data"]["id"]}
  end
end

# alias Servy.PledgeServer


# IO.inspect(PledgeServer.create_pledge("papa", 10))
# IO.inspect(PledgeServer.create_pledge("ali", 20))
# IO.inspect(PledgeServer.create_pledge("sam", 30))
# IO.inspect(PledgeServer.create_pledge("noshi", 40))
# IO.inspect(PledgeServer.create_pledge("ammi", 50))

# IO.inspect PledgeServer.recent_pledges()
