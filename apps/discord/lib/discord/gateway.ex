defmodule Discord.Gateway do
  use Supervisor

  alias Discord.Gateway.{Broker, Connection}

  def init(token) do
    children = [
      worker(Broker, [token], []),
      worker(Connection, [token], []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
