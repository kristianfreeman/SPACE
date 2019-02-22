defmodule Space.Application do
  import Supervisor.Spec

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      SpaceWeb.Endpoint,
      # Starts a worker by calling: Space.Worker.start_link(arg)
      # {Space.Worker, arg},
      worker(Cachex, [:space, []]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Space.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
