defmodule Servy.SensorServer do

  @name :sensor_server

  use GenServer

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.minutes(60)
  end


  def start_link(interval) do
    IO.puts("Starting the sensor server with #{interval} min refresh")
    initial_state = %State{sensor_data: %{}, refresh_interval: interval }
    GenServer.start_link(__MODULE__, initial_state, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(interval) do
    GenServer.cast(@name, {:change_refresh_interval, interval})
  end


  ## Server callbacks

  def init(initial_state) do
    sensor_data = run_tasks_to_get_sensor_data()
    ## Note: The process sends a message to itself, after a delay of 5 seconds, to refresh its cache.
    ######   Since its not a cast or a call, this message will be handled by handle_info callback
    schedule_refresh(initial_state.refresh_interval)
    {:ok, %{initial_state | sensor_data: sensor_data}}
  end

  def handle_cast({:change_refresh_interval, new_interval}, _from, state) do
    {:noreply, %State{ state | refresh_interval: new_interval}}
  end

  def handle_info(:refresh, state) do
    IO.puts "Refreshing the cache"
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    IO.puts("Cant touch this, #{inspect unexpected}")
    {:noreply, state}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :refresh, :timer.minutes(interval))
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  defp run_tasks_to_get_sensor_data do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
        ["cam-1", "cam-2", "cam-3"]
        |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
        |> Enum.map(&Task.await/1)

    location = Task.await(task)

    %{snapshots: snapshots, location: location}
  end


end
