defmodule Recurrencerule.RRuleRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field(:rrule, 1, type: :string)
end

defmodule Recurrencerule.DatesReply do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field(:dates, 1, repeated: true, type: Recurrencerule.Dates)
  field(:rrule, 2, type: :string)
  field(:valid, 3, type: :bool)
  field(:errors, 4, repeated: true, type: :string)
end

defmodule Recurrencerule.DataRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field(:rrules, 1, repeated: true, type: Recurrencerule.DataRrule)
  field(:ex_date, 2, repeated: true, type: :string, json_name: "exDate")
  field(:ex_rule, 3, repeated: true, type: :string, json_name: "exRule")
  field(:rdates, 4, repeated: true, type: :string)
  field(:duration, 5, type: :string)
end

defmodule Recurrencerule.DataRrule do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field(:by_week_day, 1, repeated: true, type: :string, json_name: "byWeekDay")
  field(:by_hour, 2, repeated: true, type: :uint32, json_name: "byHour")
  field(:by_minute, 3, repeated: true, type: :uint32, json_name: "byMinute")
  field(:by_month, 4, repeated: true, type: :uint32, json_name: "byMonth")
  field(:by_month_day, 5, repeated: true, type: :int32, json_name: "byMonthDay")
  field(:by_second, 6, repeated: true, type: :uint32, json_name: "bySecond")
  field(:by_set_pos, 7, repeated: true, type: :int32, json_name: "bySetPos")
  field(:by_week_no, 8, repeated: true, type: :int32, json_name: "byWeekNo")
  field(:by_year_day, 9, repeated: true, type: :int32, json_name: "byYearDay")
  field(:count, 10, type: :uint32)
  field(:dt_end, 11, type: :string, json_name: "dtEnd")
  field(:dt_start, 12, type: :string, json_name: "dtStart")
  field(:freq, 13, type: :string)
  field(:interval, 14, type: :uint32)
  field(:until, 15, type: :string)
  field(:week_start, 16, type: :int32, json_name: "weekStart")
  field(:timezone, 17, type: :string)
end

defmodule Recurrencerule.Dates do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field(:start, 1, type: :string)
  field(:end, 2, type: :string)
end

defmodule Recurrencerule.RruleProcessing.Service do
  @moduledoc false

  use GRPC.Service, name: "recurrencerule.RruleProcessing", protoc_gen_elixir_version: "0.12.0"

  rpc(:RruleToDates, Recurrencerule.RRuleRequest, Recurrencerule.DatesReply)

  rpc(:DataRruleToDates, Recurrencerule.DataRequest, Recurrencerule.DatesReply)
end

defmodule Recurrencerule.RruleProcessing.Stub do
  @moduledoc false

  use GRPC.Stub, service: Recurrencerule.RruleProcessing.Service
end

