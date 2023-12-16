defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting ServicesSupervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts("Initializing ServicesSupervisor...")
    children = [
      Servy.PledgeServer,
      {Servy.SensorServer, 60},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
