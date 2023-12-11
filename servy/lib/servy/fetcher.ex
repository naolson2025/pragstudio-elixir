defmodule Servy.Fetcher do
  def async(function) do
    parent = self()

    # runs the function in a separate process, async
    # the self() function returns the pid (process id) of the current process
    spawn(fn -> send(parent, {self(), :result, function.()}) end)
  end

  def get_result(pid) do
    # pattern match on the provided pid
    # so it will only receive messages for that pid
    receive do {^pid, :result, value} -> value end
  end
end
