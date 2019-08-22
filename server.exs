defmodule TcpEchoServer do

  def start_server(port) do
    IO.puts("starting server")
    IO.inspect(self())

    case :gen_tcp.listen(port, [:binary, {:active, false}]) do
      {:ok, listen_socket} -> 
        spawn_link(fn -> acceptor(listen_socket) end)
        Process.sleep(:infinity)
      {:error, :eaddrinuse} ->
        IO.puts "address in use"
    end
  end

  def acceptor(listen_socket) do
    IO.puts("starting acceptor")
    IO.inspect(self())

    # this will block, waiting for a connection
    {:ok, accept_socket} = :gen_tcp.accept(listen_socket)

    # spawn a signal handler process which will get exit signals from this process, and trap them
    spawn_link(fn -> sighandler() end)

    # spawn same func to wait for other clients
    spawn_link(fn -> acceptor(listen_socket) end)

    handle(accept_socket)
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

  def handle(accept_socket) do
    IO.puts "handle"
    :inet.setopts(accept_socket, [{:active, :once}])
    receive do
      {:tcp, accept_socket, "quit\r\n"} -> 
        :gen_tcp.close(accept_socket)
      {:tcp, accept_socket, message} ->
        :gen_tcp.send(accept_socket, message)
        handle(accept_socket)
    end
  end
end

_pid = TcpEchoServer.start_server(3001)
