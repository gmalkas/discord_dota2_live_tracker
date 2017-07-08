defmodule Discord.Gateway.Session do
  use GenServer

  defstruct [:id, :token, :seq, :url]

  alias __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(:discord_gateway_sessions, [])
    {:ok, table}
  end

  def store(token, url, session_id, seq) do
    GenServer.call(__MODULE__, {:store, token, url, session_id, seq})
  end

  def update_seq(token, seq) do
    GenServer.call(__MODULE__, {:update_seq, token, seq})
  end

  def last_seq_received(token) do
    GenServer.call(__MODULE__, {:last_seq_received, token})
  end

  def find(token) do
    GenServer.call(__MODULE__, {:find, token})
  end

  def exists?(token) do
    GenServer.call(__MODULE__, {:exists, token})
  end

  def handle_call({:store, token, url, session_id, seq}, _caller, table) do
    :ets.insert(table, {token, %Session{id: session_id, token: token, seq: seq, url: url}})

    {:reply, :ok, table}
  end

  def handle_call({:update_seq, token, seq}, _caller, table) do
    [{_, %Session{} = session}] = :ets.lookup(table, token)
    :ets.insert(table, {token, %Session{session | seq: seq}})

    {:reply, :ok, table}
  end

  def handle_call({:last_seq_received, token}, _caller, table) do
    case :ets.lookup(table, token) do
      [{_, %Session{seq: last_seq_received}}] -> {:reply, last_seq_received, table}
      [] -> {:reply, nil, table}
    end
  end

  def handle_call({:find, token}, _caller, table) do
    case :ets.lookup(table, token) do
      [{_, %Session{} = session}] -> {:reply, {:ok, session}, table}
      [] -> {:reply, {:error, :not_found}, table}
    end
  end

  def handle_call({:exists, token}, _caller, table) do
    case :ets.lookup(table, token) do
      [{_, %Session{} = session}] -> {:reply, true, table}
      [] -> {:reply, false, table}
    end
  end
end
