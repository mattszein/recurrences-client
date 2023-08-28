defmodule RecurrencesClient.Repo.Migrations.CreateRrules do
  use Ecto.Migration

  def change do
    create table(:rrules) do
      add(:name, :string)
      add(:rrule, :string)
      add(:by_hour, {:array, :integer})
      add(:by_minute, {:array, :integer})
      add(:by_month, {:array, :integer})
      add(:by_month_day, {:array, :integer})
      add(:by_second, {:array, :integer})
      add(:by_set_pos, {:array, :integer})
      add(:by_week_day, {:array, :string})
      add(:by_week_no, {:array, :integer})
      add(:by_year_day, {:array, :integer})
      add(:count, :integer)
      add(:dt_start, :utc_datetime)
      add(:freq, :string)
      add(:interval, :integer)
      add(:until, :utc_datetime)
      add(:week_start, :integer)

      timestamps()
    end
  end
end
