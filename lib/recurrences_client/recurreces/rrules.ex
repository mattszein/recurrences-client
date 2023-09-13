defmodule RecurrencesClient.Recurreces.Rrules do
  use Ecto.Schema
  import Ecto.Changeset
  @schema_meta_fields [:__meta__]

  schema "rrules" do
    field(:by_hour, {:array, :integer})
    field(:by_minute, {:array, :integer})
    field(:by_month, {:array, :integer})
    field(:by_month_day, {:array, :integer})
    field(:by_second, {:array, :integer})
    field(:by_set_pos, {:array, :integer})

    field(:by_week_day, {:array, :string})

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
    field(:week_start, Ecto.Enum, values: [MO: 0, TU: 1, WE: 2, TH: 3, FR: 4, SA: 5, SU: 6])

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
      :freq
    ])
    |> validate_related_required(:until)
    |> validate_until_and_dstart()
    |> validate_weekday()
    |> validate_subset(:by_month_day, -31..31)
    |> validate_subset(:by_year_day, -366..366)
    |> validate_subset(:by_week_no, -53..53)
    |> validate_subset(:by_month, 1..12)
    |> validate_subset(:by_set_pos, -366..366)
  end

  defp validate_until_and_dstart(changeset) do
    until = Ecto.Changeset.get_change(changeset, :until)

    case until != nil && until <= Ecto.Changeset.get_change(changeset, :dt_start) do
      true ->
        add_error(changeset, :until, "Until can't be minor than dt_start")

      false ->
        changeset
    end
  end

  defp validate_related_required(changeset, field, _opts \\ []) do
    case Ecto.Changeset.get_field(changeset, field) != nil ||
           Ecto.Changeset.get_field(changeset, :count) != nil do
      true ->
        changeset

      false ->
        add_error(changeset, field, "Until is needed when count is not filled")
    end
  end

  defp validate_weekday(changeset) do
    weekdays = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    days = Ecto.Changeset.get_field(changeset, :by_week_day)
    freq = Ecto.Changeset.get_field(changeset, :freq)
    weekno = Ecto.Changeset.get_field(changeset, :by_week_no)

    case days do
      nil ->
        changeset

      [_] when freq == :YEARLY and weekno != [] ->
        add_error(
          changeset,
          :by_week_day,
          "MUST NOT be specified with a numeric value with the FREQ rule part set to YEARLY when the BYWEEKNO rule part is specified."
        )

      values ->
        Enum.reduce(values, changeset, fn val, ch ->
          if String.match?(val, ~r/(^[+|-])([0-9])*([A-Z]{2})$|(^[A-Z]{2})$/) do
            if String.length(val) > 2 && (freq != :YEARLY && freq != :MONTHLY) do
              add_error(
                ch,
                :by_week_day,
                "Value #{val} is invalid, MUST NOT be specified with a numeric value when the FREQ rule part is not set to MONTHLY or YEARLY."
              )
            else
              if Enum.member?(weekdays, String.slice(val, -2, 2)) do
                ch
              else
                add_error(ch, :by_week_day, "Bad Format. Day #{val} is invalid")
              end
            end
          else
            add_error(ch, :by_week_day, "Bad Format. Value #{val} is invalid")
          end
        end)
    end
  end

  def rrule_keys do
    [
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
    ]
  end

  def date_to_string(date) when date == nil do
    nil
  end

  def date_to_string(date) do
    NaiveDateTime.to_iso8601(date)
  end
end
