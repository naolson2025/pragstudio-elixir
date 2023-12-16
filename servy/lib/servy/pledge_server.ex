defmodule Servy.PledgeServer do
  @name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # This will run in the client process
  def start_link(_args) do
    IO.puts("Starting PledgeServer...")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end
  # called by the client
  # sends message to the listen_loop
  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, :total_pledged)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def set_cache_size(size) do
    GenServer.cast @name, {:set_cache_size, size}
  end

  ## Server callbacks

  # called by GenServer.start, used to load initial data
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{state | cache_size: size}
    {:noreply, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    # take the first two pledges from the state
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    # add the new pledge to the front of the list
    # this way we always have the 3 most recent pledges
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}
    IO.puts("#{name} pledged #{amount}!")
    IO.puts("New state is #{inspect(new_state)}")
    {:reply, id, new_state}
  end

  def handle_info(msg, state) do
    IO.puts("Can't touch this")
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # send the pledge to the external service
    # not going to actually send in this course
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # fetch the pledges from the external service
    # not going to actually fetch in this course
    [
      {"wilma", 15},
      {"fred", 25}
    ]
  end
end

# alias Servy.PledgeServer

# {:ok, pid} = PledgeServer.start()

# send(pid, {:stop, "hammertime"})

# PledgeServer.set_cache_size(4)

# IO.inspect(PledgeServer.create_pledge("larry", 10))
# PledgeServer.clear()
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect(PledgeServer.create_pledge("grace", 50))

# IO.inspect(PledgeServer.recent_pledges())

# IO.inspect(PledgeServer.total_pledged())
