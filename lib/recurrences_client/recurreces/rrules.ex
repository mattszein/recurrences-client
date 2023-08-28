defmodule RecurrencesClient.Recurreces.Rrules do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rrules" do
    field(:by_hour, {:array, :integer})
    field(:by_minute, {:array, :integer})
    field(:by_month, {:array, :integer})
    field(:by_month_day, {:array, :integer})
    field(:by_second, {:array, :integer})
    field(:by_set_pos, {:array, :integer})

    field(:by_week_day, {:array, Ecto.Enum}, values: [:MO, :TU, :WE, :TH, :FR, :SA, :SU])

    field(:by_week_no, {:array, :integer})
    field(:by_year_day, {:array, :integer})
    field(:count, :integer)
    field(:dt_start, :naive_datetime)

    field(
      :freq,
      Ecto.Enum,
      values: [:YEARLY, :MONTHLY, :WEEKLY, :DAILY, :HOURLY, :MINUTELY, :SECONDLY]
    )

    field(:interval, :integer)
    field(:until, :naive_datetime)
    field(:week_start, :integer)

    field(:name, :string)
    field(:rrule, :string)
    timestamps()
  end

  @doc false
  def changeset(rrules, attrs) do
    rrules
    |> cast(attrs, [
      :name,
      :by_hour,
      :by_minute,
      :by_month,
      :by_month_day,
      :by_second,
      :by_set_pos,
      :by_week_day,
      :by_week_no,
      :by_year_day,
      :count,
      :dt_start,
      :freq,
      :interval,
      :until,
      :week_start,
      :rrule
    ])
    |> validate_required([
      :dt_start,
      :freq,
      :until
    ])
  end
end
