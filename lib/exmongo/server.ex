defmodule Exmongo.Server do
  use GenServer

  def start(host, port, db) do
    GenServer.start(__MODULE__, {host, port, db})
  end

  def init({host, port, db}) do
    send(self, {:connect, {host, port, db}})
    {:ok, nil}
  end

  def handle_info({:connect, {host, port, db}}, _) do
    {:ok, conn} = :mongo.connect(host, port, db)
    {:noreply, conn}
  end
end