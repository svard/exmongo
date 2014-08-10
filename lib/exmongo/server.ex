defmodule Exmongo.Server do
  use GenServer
  import Exmongo.ObjectId

  def start(host, port, db) do
    GenServer.start(__MODULE__, {host, port, db})
  end

  def find(pid, collection, selector) do
    GenServer.call(pid, {:find, collection, selector})
  end

  def init({host, port, db}) do
    send(self, {:connect, {host, port, db}})
    {:ok, nil}
  end

  def handle_info({:connect, {host, port, db}}, _) do
    {:ok, conn} = :mongo.connect(host, port, db)
    {:noreply, conn}
  end

  def handle_call({:find, collection, selector}, _, conn) do
    cursor = :mongo.find(conn, collection, selector)
    {:reply, process_cursor([], cursor), conn}
  end

  defp process_cursor(acc, cursor) do
    case :mc_cursor.next(cursor) do
      {data} ->
#        [:bson.fields(data) | acc]
        [objectid_to_string(:bson.fields(data)) | acc]
        |> process_cursor(cursor)
      
      _ ->
        :mc_cursor.close(cursor)
        acc
    end
  end


end