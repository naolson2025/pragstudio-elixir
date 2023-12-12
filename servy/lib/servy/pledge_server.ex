defmodule Servy.PledgeServer do

  def listen_loop(state) do
    IO.puts("\nWaiting for a message...")

    receive do
      {:create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        new_state = [ {name, amount} | state]
        IO.puts("#{name} pledged #{amount}!")
        IO.puts("New state is #{inspect new_state}")
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        IO.puts("Sent recent pledges to #{inspect sender}")
        listen_loop(state)
    end
  end

  # def create_pledge(name, amount) do
  #   {:ok, id} = send_pledge_to_service(name, amount)

  #   # cache the pledge
  #   [{"larry", 10}]
  # end

  # def recent_pledges() do
  #   # get the pledges from the cache
  #   [{"larry", 10}]
  # end

  defp send_pledge_to_service(_name, _amount) do
    # send the pledge to the external service
    # not going to actually send in this course
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
