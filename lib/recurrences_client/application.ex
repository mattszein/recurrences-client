defmodule RecurrencesClient.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RecurrencesClientWeb.Telemetry,
      # Start the Ecto repository
      RecurrencesClient.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: RecurrencesClient.PubSub},
      # Start Finch
      {Finch, name: RecurrencesClient.Finch},
      # Start the Endpoint (http/https)
      RecurrencesClientWeb.Endpoint
      # Start a worker by calling: RecurrencesClient.Worker.start_link(arg)
      # {RecurrencesClient.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RecurrencesClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RecurrencesClientWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
