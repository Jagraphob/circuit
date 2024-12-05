defmodule Circuit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CircuitWeb.Telemetry,
      Circuit.Repo,
      {DNSCluster, query: Application.get_env(:circuit, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Circuit.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Circuit.Finch},
      # Start a worker by calling: Circuit.Worker.start_link(arg)
      # {Circuit.Worker, arg},
      # Start to serve requests, typically the last entry
      CircuitWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Circuit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CircuitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
