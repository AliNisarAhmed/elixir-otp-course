defmodule Servy.PledgeServer do

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  @process_name :pledge_server
  @url "https://httparrot.herokuapp.com/post"

  # Client facing functions

  def start_link(_arg) do
    IO.puts("Starting the pledge server")
    GenServer.start_link(__MODULE__, %State{}, name: @process_name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@process_name, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@process_name, :total_pledged)
  end

  def clear(pid, message) do
    GenServer.cast(pid, message)
  end

  def set_cache_size(size) do
    GenServer.cast(@process_name, {:set_cache_size, size})
  end

  #### init function : Genserver Contract
  def init(state) do
    pledges = fetch_recent_pledges()
    {:ok, %{state | pledges: pledges }}
  end

  ### handle_cast and handle_call are required by the GenServer contract
  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_pledges = Enum.take(state.pledges, size)
    new_state = %{state | pledges: new_pledges, cache_size: size }
    {:noreply, new_state}
  end



  def handle_call(:total_pledged, _from, state) do
    total = state.pledges
      |> Enum.map(fn {_ , amount} -> amount end)
      |> Enum.sum()
    {:reply, total, state }
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [ {name, amount} | most_recent ]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_info(message, state) do
    IO.puts("Can't touch this! #{inspect message}")
    {:noreply, state}
  end

  ###### Internal module functions

  defp send_pledge_to_service(name, amount) do
    # {:ok, "pledge-#{:rand.uniform(1000)}"}
    body = ~s({"name" : "#{name}", "amount": "#{amount}", "id": "#{:rand.uniform(1000)}" })
    headers = ~s({"Content-Type": "application/json"})
    {:ok, response} = HTTPoison.post(@url, body, headers)
    body = Poison.Parser.parse!(response.body, %{})
    {:ok, body["data"]["id"]}
  end

  def fetch_recent_pledges do
    [{"Ali", 100}, {"Sam", 200}]
  end
end

# alias Servy.PledgeServer


# IO.inspect(PledgeServer.create_pledge("papa", 10))
# IO.inspect(PledgeServer.create_pledge("ali", 20))
# IO.inspect(PledgeServer.create_pledge("sam", 30))
# IO.inspect(PledgeServer.create_pledge("noshi", 40))
# IO.inspect(PledgeServer.create_pledge("ammi", 50))

# IO.inspect PledgeServer.recent_pledges()
