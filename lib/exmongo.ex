defmodule Exmongo do
  def start do
    :application.start(:bson)
    :application.start(:mongodb)
  end

  def connect(host, port, db) when is_list(host) and is_integer(port) and is_binary(db) do
    Exmongo.Server.start(host, port, db)
  end

  def find_all(pid, collection) do
    Exmongo.Server.find(pid, collection, {})
  end
end
