defmodule RecurrencesClient.ServicesConnections do
  def get_table do
    case :ets.whereis(:grpc_connections) do
      :undefined -> :ets.new(:grpc_connections, [:set, :protected, :named_table])
      ref -> ref
    end
  end

  def get_channel(table) do
    :ets.lookup(table, :channel)
  end

  def get_connection do
    t = get_table()
    a = get_channel(t)

    case a do
      [{:channel, chan}] ->
        chan

      [] ->
        {:ok, chan} = GRPC.Stub.connect("server:4400")
        :ets.insert(t, {:channel, chan})
        chan
    end
  end
end
