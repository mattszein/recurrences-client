defmodule Recurrencesclient.ProcessRrule do
  alias RecurrencesClient.ServicesConnections

  def default_data_rrule do
    %Recurrencerule.DataRrule{
      by_week_day: [],
      by_hour: [],
      by_minute: [],
      by_month: [],
      by_month_day: [],
      by_second: [],
      by_set_pos: [],
      by_week_no: [],
      by_year_day: [],
      count: 0,
      dt_start: nil,
      dt_end: nil,
      freq: nil,
      interval: 1,
      until: nil,
      week_start: 0
    }
  end

  def process_data(params) do
    parsed_data = parse_model(params)
    request = Map.merge(default_data_rrule(), parsed_data)
    con = ServicesConnections.get_connection()
    {:ok, reply} = con |> Recurrencerule.RruleProcessing.Stub.data_rrule_to_dates(request)
    reply
  end

  def parse_model(model) do
    model
    |> parse_date(:dt_start, Map.get(model, :dt_start))
    |> parse_date(:until, Map.get(model, :until))
    |> Map.update!(:freq, &Atom.to_string(&1))
  end

  def parse_date(model, _key, value) when value == nil do
    model
  end

  def parse_date(model, key, _value) do
    model
    |> Map.update!(key, &date_to_string/1)
  end

  def date_to_string(date) do
    NaiveDateTime.to_iso8601(date)
  end
end
