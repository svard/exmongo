defmodule Exmongo do
  def start do
    :application.start(:bson)
    :application.start(:mongodb)
  end

  def connect(host, port, db) when is_list(host) and is_integer(port) and is_binary(db) do
    Exmongo.Server.start(host, port, db)
  end

  def find_all(pid, collection, opts \\ []) do
    Exmongo.Server.find(pid, collection, {}, opts[:fields])
  end

  def find(pid, collection, selector, opts \\ []) do
    Exmongo.Server.find(pid, collection, selector, opts[:fields])
  end

  def insert(pid, collection, doc) do
    Exmongo.Server.insert(pid, collection, doc)
  end
end
