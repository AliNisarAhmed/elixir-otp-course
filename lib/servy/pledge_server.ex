defmodule Servy.GenericServer do

  def start(callback_module, initial_state, name) do
    IO.puts "Starting the pledge server"
    pid = spawn(__MODULE__, :listen_loop, [callback_module, initial_state])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

   # Server functions
  def listen_loop(callback_module, state) do
    receive do

      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, response)
        listen_loop(callback_module, new_state)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(callback_module, new_state)

      unexpected ->
        IO.puts "Unexpected message #{inspect unexpected}"
        listen_loop(callback_module, state)
    end

  end

end

defmodule Servy.PledgeServer do

  alias Servy.GenericServer

  @process_name :pledge_server
  @url "https://httparrot.herokuapp.com/post"

  # Client facing functions

  def start do
    GenericServer.start(__MODULE__, [], @process_name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@process_name, :recent_pledges)
  end

  def total_pledged() do
    GenericServer.call(@process_name, :total_pledged)
  end

  def clear(pid, message) do
    GenericServer.cast(pid, message)
  end

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledged, state) do
    total = state
      |> Enum.map(fn {_ , amount} -> amount end)
      |> Enum.sum()
    { total, state }
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent = Enum.take(state, 2)
    new_state = [ {name, amount} | most_recent ]
    {id, new_state}
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
