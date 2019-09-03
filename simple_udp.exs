defmodule SimpleUdpServer do

  def start_server(port) do

    case :gen_udp.open(port, [:binary, {:active, true}]) do
      {:ok, socket} -> 
        handle(socket)
        Process.sleep(:infinity)
      {:error, :eaddrinuse} ->
        IO.puts "address in use"
    end
  end

  def handle(socket) do
    IO.puts "handle"
    receive do
      {:udp, socket, _addr, _port, message} -> 
        IO.puts "got message"
      _ ->
        IO.puts "got ohter"
        # handle(socket)
    end
    IO.puts "skip"
  end
end

_pid = SimpleUdpServer.start_server(3001)
