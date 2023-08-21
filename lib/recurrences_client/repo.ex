defmodule RecurrencesClient.Repo do
  use Ecto.Repo,
    otp_app: :recurrences_client,
    adapter: Ecto.Adapters.Postgres
end
