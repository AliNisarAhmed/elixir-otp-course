defmodule Servy.FourOhFourCounter do
  use GenServer

  @process_name :four_oh_four_counter

  def start do
    GenServer.start(__MODULE__, %{}, name: @process_name)
  end

  def bump_count(route) do
    GenServer.call(@process_name, {:bump_count, route})
  end

  def get_count(route) do
    GenServer.call(@process_name, {:get_count, route})
  end

  def get_counts do
    GenServer.call(@process_name, :get_counts)
  end

  def clear_counts do
    GenServer.cast(@process_name, :clear_counts)
  end

  #### GenServer callback functions

  def init(state) do
    {:ok, state}
  end

  def handle_cast(:clear_counts, _state) do
    {:noreply, %{}}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state}
  end

  def handle_call({:get_count, route}, _from, state) do
    {:reply, Map.get(state, route, 0), state}
  end

  def handle_call({:bum_count, route}, _from, state) do
    new_state = Map.update(state, route, 1, fn v -> v + 1 end)
    {:reply, Map.get(new_state, route, 0), new_state}
  end

end


## Old code using Custom GenericServer, left here for comparison

# defmodule Servy.FourOhFourCounter.GenericServer do
#   def start(callback_module, initial_state, name) do
#     pid = spawn(__MODULE__, :listen_loop, [callback_module, initial_state])
#     Process.register(pid, name)
#     pid
#   end

#   def call(pid, message) do
#     send(pid, {:call, self(), message })

#     receive do {:response, response} -> response end
#   end

#   def cast(pid, message) do
#     send(pid, {:cast, message})
#   end

#   def listen_loop(callback_module, state) do
#     receive do
#       {:call, sender, message} ->
#         {response, new_state} = callback_module.handle_call(message, state)
#         send(sender, response)
#         listen_loop(callback_module, new_state)

#       {:cast, message} ->
#         new_state = callback_module.handle_cast(message, state)
#         listen_loop(callback_module, new_state)

#       unexpected ->
#         IO.puts("Unexpected message: #{inspect unexpected}")
#         listen_loop(callback_module, state)
#     end

#   end

# end





# defmodule Servy.FourOhFourCounter do
#   @process_name __MODULE__

#   alias Servy.FourOhFourCounter.GenericServer

#   def start do
#     GenericServer.start(__MODULE__, %{}, @process_name)
#   end

#   def bump_count(route) do
#     GenericServer.call(@process_name, {:bump_count, route})
#   end

#   def get_count(route) do
#     GenericServer.call(@process_name, {:get_count, route})
#   end

#   def get_counts do
#     GenericServer.call(@process_name, :get_counts)
#   end

#   def clear_counts do
#     GenericServer.cast(@process_name, :clear_counts)
#   end


#   ## Server functions
#   def handle_call({:bump_count, route}, state) do
#     new_state = Map.update(state, route, 1, fn v -> v + 1 end)
#     {Map.get(state, route, 0), new_state}
#   end

#   def handle_call({:get_count, route}, state) do
#     {Map.get(state, route, 0), state}
#   end

#   def handle_call(:get_counts, state) do
#     {state, state}
#   end

#   def handle_cast(:clear_counts, _state) do
#     %{}
#   end
# end
