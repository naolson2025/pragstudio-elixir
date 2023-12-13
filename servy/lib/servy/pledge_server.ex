defmodule Servy.PledgeServer do
  @name :pledge_server

  ## Client interface functions
  # called by the client to spawn the server process
  def start do
    IO.puts("Starting PledgeServer...")
    pid = spawn(__MODULE__, :listen_loop, [[]])
    # register the pid with the name :pledge_server
    # we can choose any name we want, but we'll use :pledge_server
    # That way other functions can send messages to it
    # like a global variable
    Process.register(pid, @name)
    pid
  end

  # This will run in the client process
  # called by the client
  # sends message to the listen_loop
  def create_pledge(name, amount) do
    send(@name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges() do
    send(@name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged do
    send @name, {self(), :total_pledged}

    receive do {:response, total} -> total end
  end

  ## Server functions

  def listen_loop(state) do
    IO.puts("\nWaiting for a message...")

    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        # take the first two pledges from the state
        most_recent_pledges = Enum.take(state, 2)
        # add the new pledge to the front of the list
        # this way we always have the 3 most recent pledges
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        IO.puts("#{name} pledged #{amount}!")
        IO.puts("New state is #{inspect(new_state)}")
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        IO.puts("Sent recent pledges to #{inspect(sender)}")
        listen_loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
        send sender, {:response, total}
        listen_loop(state)
      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # send the pledge to the external service
    # not going to actually send in this course
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

pid = PledgeServer.start

send pid, {:stop, "hammertime"}

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))
IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledged())
