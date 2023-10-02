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
    grpc_server = System.get_env("GRPC_SERVER_HOST") <> ":" <> System.get_env("GRPC_SERVER_PORT")

    case a do
      [{:channel, chan}] ->
        chan

      [] ->
        {:ok, chan} = GRPC.Stub.connect(grpc_server)
        :ets.insert(t, {:channel, chan})
        chan
    end
  end
end
