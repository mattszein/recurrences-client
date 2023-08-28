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
    request = Map.merge(default_data_rrule(), params)
    con = ServicesConnections.get_connection()
    {:ok, reply} = con |> Recurrencerule.RruleProcessing.Stub.data_rrule_to_dates(request)
    reply
  end
end
