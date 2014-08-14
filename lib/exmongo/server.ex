defmodule Exmongo.Server do
  use GenServer
  import Exmongo.ObjectId

  def start(host, port, db) do
    GenServer.start(__MODULE__, {host, port, db})
  end

  def find(pid, collection, selector, fields) do
    GenServer.call(pid, {:find, collection, selector, fields})
  end

  def insert(pid, collection, doc) do
    GenServer.cast(pid, {:insert, collection, doc})
  end

  def init({host, port, db}) do
    send(self, {:connect, {host, port, db}})
    {:ok, nil}
  end

  def handle_info({:connect, {host, port, db}}, _) do
    {:ok, conn} = :mongo.connect(host, port, db)
    {:noreply, conn}
  end

  def handle_call({:find, collection, selector, fields}, _, conn) do
    cursor = :mongo.find(conn, collection, selector)
    {:reply, process_cursor([], cursor, fields), conn}
  end

  def handle_cast({:insert, collection, doc}, conn) do
    :mongo.insert(conn, collection, doc)
    {:noreply, conn}
  end

  defp process_cursor(acc, cursor, nil) do
    case :mc_cursor.next(cursor) do
      {data} ->
        [objectid_to_string(:bson.fields(data)) | acc]
        |> process_cursor(cursor, nil)
      
      _ ->
        :mc_cursor.close(cursor)
        acc
    end
  end

  defp process_cursor(acc, cursor, fields) do
    case :mc_cursor.next(cursor) do
      {data} ->
        selected_fields =
        objectid_to_string(:bson.fields(data))
        |> Dict.take(fields)

        [selected_fields | acc]
        |> process_cursor(cursor, fields)
      
      _ ->
        :mc_cursor.close(cursor)
        acc
    end
  end
end