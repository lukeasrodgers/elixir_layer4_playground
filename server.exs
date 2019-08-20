defmodule TcpEchoServer do

  def start_server(port) do
    case :gen_tcp.listen(port, [:binary, {:active, false}]) do
      {:ok, listen_socket} -> 
        spawn(fn -> acceptor(listen_socket) end)
        Process.sleep(:infinity)
      {:error, :eaddrinuse} ->
        IO.puts "address in use"
    end
  end

  def acceptor(listen_socket) do
    # this will block, I think?
    {:ok, accept_socket} = :gen_tcp.accept(listen_socket)
    # span same func to wait for other clients
    spawn(fn -> acceptor(listen_socket) end)

    handle(accept_socket)
  end

  def handle(accept_socket) do
    :inet.setopts(accept_socket, [{:active, :once}])
    receive do
      {:tcp, accept_socket, <<"quit", _::binary>>} -> 
        :gen_tcp.close(accept_socket)
      {:tcp, accept_socket, message} ->
        :gen_tcp.send(accept_socket, message)
        handle(accept_socket)
    end
  end
end

_pid = TcpEchoServer.start_server(3001)
