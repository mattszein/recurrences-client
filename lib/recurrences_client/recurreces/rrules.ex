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
      :freq
    ])
    |> validate_related_required(:until)
    |> validate_until_and_dstart()
    |> validate_weekday()
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
    values = Ecto.Changeset.get_change(changeset, :by_week_day)

    if values == nil do
      changeset
    else
      Enum.reduce(values, changeset, fn val, ch ->
        if String.match?(val, ~r/(^[+|-])([0-9])*([A-Z]{2})$|(^[A-Z]{2})$/) do
          wd = String.slice(val, -2, 2)

          if Enum.member?(weekdays, wd) do
            ch
          else
            add_error(ch, :by_week_day, "Bad Format. Value #{val} is invalid")
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

  def to_storeable_map(struct) do
    association_fields = struct.__struct__.__schema__(:associations)
    waste_fields = association_fields ++ @schema_meta_fields ++ [:name, :updated_at, :inserted_at]

    struct
    |> Map.from_struct()
    |> Map.drop(waste_fields)
    |> Map.update!(:dt_start, &date_to_string/1)
    |> Map.update(:until, nil, &date_to_string/1)
    |> Map.update!(:freq, &Atom.to_string(&1))
  end

  def date_to_string(date) when date == nil do
    nil
  end

  def date_to_string(date) do
    NaiveDateTime.to_iso8601(date)
  end
end
