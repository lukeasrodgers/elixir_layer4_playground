defmodule UdpEchoServer do

  def start_server(port) do
    IO.puts("starting UDP server")
    IO.inspect(self())

    case :gen_udp.open(port, [:binary, {:active, true}]) do
      {:ok, socket} -> 
        acceptor(socket)
      {:error, :eaddrinuse} ->
        IO.puts "address in use"
    end
  end

  def acceptor(socket) do
    IO.puts("starting acceptor")
    IO.inspect(self())

    # spawn a signal handler process which will get exit signals from this process, and trap them
    spawn_link(fn -> sighandler() end)

    handle(socket)
  end

  def sighandler do
    IO.puts "sighandler"
    Process.flag(:trap_exit, true)
    receive do
      {:EXIT, from, reason} ->
        IO.puts("exit")
        IO.inspect(from)
        IO.puts("reason")
        IO.inspect(reason)
      {:normal, from, reason} ->
        IO.puts("recieved normal exit" <> from <> "reason: " <> reason)
    end
  end

  def handle(socket) do
    receive do
      {:udp, socket, "quit\r\n"} -> 
        :gen_udp.close(socket)
      {:udp, socket, addr, port, message} ->
        IO.puts "got message: #{message}"
        :gen_udp.send(socket, message)
      _ ->
        IO.puts "got ohter"
    end
    handle(socket)
  end
end

_pid = UdpEchoServer.start_server(3001)
