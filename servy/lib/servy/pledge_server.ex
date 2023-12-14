defmodule Servy.GenericServer do
  ## Client interface functions
  # called by the client to spawn the server process
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    # register the pid with the name :pledge_server
    # we can choose any name we want, but we'll use :pledge_server
    # That way other functions can send messages to it
    # like a global variable
    Process.register(pid, name)
    pid
  end

  # helper functions
  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  ## Server functions

  def listen_loop(state, callback_module) do
    IO.puts("\nWaiting for a message...")

    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.PledgeServer do
  alias Servy.GenericServer
  @name :pledge_server

  # This will run in the client process
  def start do
    IO.puts("Starting PledgeServer...")
    GenericServer.start(__MODULE__, [], @name)
  end
  # called by the client
  # sends message to the listen_loop
  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@name, :clear)
  end

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    # take the first two pledges from the state
    most_recent_pledges = Enum.take(state, 2)
    # add the new pledge to the front of the list
    # this way we always have the 3 most recent pledges
    new_state = [{name, amount} | most_recent_pledges]
    IO.puts("#{name} pledged #{amount}!")
    IO.puts("New state is #{inspect(new_state)}")
    {id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # send the pledge to the external service
    # not going to actually send in this course
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

pid = PledgeServer.start()

send(pid, {:stop, "hammertime"})

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))

PledgeServer.clear()

IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledged())
