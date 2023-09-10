defmodule RecurrencesClientWeb.RrulesLive.FormComponent do
  use RecurrencesClientWeb, :live_component
  import Phoenix.HTML.Form

  alias RecurrencesClient.Recurreces
  alias RecurrencesClient.Recurreces.Rrules
  alias Recurrencesclient.ProcessRrule

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border-b border-gray-900/10 w-full">
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage rrules records in your database.</:subtitle>
      </.header>

    <div class="flex flex-row space-x-4">
      <div class="basis-3/4">
        <.simple_form
          for={@form}
          id="rrules-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input field={@form[:rrule]} type="text" label="RRule" readonly />
          <.input field={@form[:name]} type="text" label="Name" />
          <.input
            field={@form[:freq]}
            type="select"
            label="Freq"
            prompt="Choose a value"
            options={Ecto.Enum.values(RecurrencesClient.Recurreces.Rrules, :freq)}
            tooltip="The frequency of the recurrence. Must be one of YEARLY, MONTHLY, WEEKLY, DAILY, HOURLY, MINUTELY, or SECONDLY."
          />
          <.input field={@form[:by_hour]} type="text" label="By Hour" value={input_value(@form, :by_hour) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, meaning the hours to apply the recurrence to." />
          <.input field={@form[:by_minute]} type="text" label="By Minute"  value={input_value(@form, :by_minute) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, meaning the minutes to apply the recurrence to."/> 
          <.input field={@form[:by_month]} type="text" label="By Month" value={input_value(@form, :by_month) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, meaning the months to apply the recurrence to." />
          <.input field={@form[:by_month_day]} type="text" label="By Month Day" value={input_value(@form, :by_month_day) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, meaning the month days to apply the recurrence to." />
          <.input field={@form[:by_second]} type="text" label="By Second" value={input_value(@form, :by_second) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, meaning the seconds to apply the recurrence to."/>
          <.input field={@form[:by_set_pos]} type="text" label="By Set pos" value={input_value(@form, :by_set_pos) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, positive or negative. Each given integer will specify an occurrence number, corresponding to the nth occurrence of the rule inside the frequency period. For example, a bysetpos of -1 if combined with a MONTHLY frequency, and a byweekday of (MO, TU, WE, TH, FR), will result in the last work day of every month."/>

         <.input
            field={@form[:by_week_day]}
            type="select"
            multiple
            label="By week day"
            options={[{"MO", "MO"}, {"TU","TU"}, {"WE","WE"}, {"TH","TH"}, {"FR", "FR"}, {"SA","SA"}, {"SU","SU"}]}
            tooltip="If given, it must be either an integer (0 == MO), a sequence of integers, one of the weekday constants (MO, TU, etc), or a sequence of these constants. When given, these variables will define the weekdays where the recurrence will be applied. It’s also possible to use an argument n for the weekday instances, which will mean the nth occurrence of this weekday in the period. For example, with MONTHLY, or with YEARLY and BYMONTH, using FR(+1) in byweekday will specify the first friday of the month where the recurrence happens. Notice that in the RFC documentation, this is specified as BYDAY, but was renamed to avoid the ambiguity of that keyword."
          />
          <.input field={@form[:by_week_no]} type="text" label="By Week no" value={input_value(@form, :by_week_no) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, meaning the week numbers to apply the recurrence to. Week numbers have the meaning described in ISO8601, that is, the first week of the year is that containing at least four days of the new year." />
          <.input field={@form[:by_year_day]} type="text" label="By Year Day" value={input_value(@form, :by_year_day) |> serialise_array} tooltip="If given, it must be either an integer, or a sequence of integers, meaning the year days to apply the recurrence to."/>
          <.input field={@form[:count]} type="number" label="Count" tooltip="If given, this determines how many occurrences will be generated. Cannot use in conjunction with until"/>
          <.input field={@form[:dt_start]} type="datetime-local" label="Dt start" tooltip="The recurrence start. Besides being the base for the recurrence, missing parameters in the final recurrence instances will also be extracted from this date" />
          <.input field={@form[:interval]} type="number" label="Interval" tooltip="The interval between each freq iteration. For example, when using YEARLY, an interval of 2 means once every two years, but with HOURLY, it means once every two hours. The default interval is 1."/>
          <.input field={@form[:until]} type="datetime-local" label="Until" tooltip="If given, this must be a datetime instance specifying the upper-bound limit of the recurrence. The last recurrence in the rule is the greatest datetime that is less than or equal to the value specified in the until parameter."/>
          <.input field={@form[:week_start]} type="number" label="Week start" tooltip="The week start day. Must be one of the MO, TU, WE constants, or an integer, specifying the first day of the week. This will affect recurrences based on weekly periods. "/>

          <:actions>
            <.button phx-disable-with="Saving...">Save Rrules</.button>
          </:actions>
        </.simple_form>
        </div>
        <div class="basis-1/4">
          <.table id="dates" rows={@dates}>
            <:col :let={date} label="Dates"><%= date %></:col>
            <:col :let={date} label="Date"> 
              <%= string_to_date(date) %> 
            </:col>
           e
          </.table>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{rrules: rrules} = assigns, socket) do
    changeset = Recurreces.change_rrules(rrules)

    socket_assign =
      socket
      |> assign(assigns)

    new_socket = process_rrule(socket_assign, changeset)

    {:ok, new_socket}
  end

  @impl true
  def handle_event("validate", %{"rrules" => rrules_params}, socket) do
    rrules_deserialise = text_inputs_to_arrays(rrules_params)

    changeset =
      socket.assigns.rrules
      |> Recurreces.change_rrules(rrules_deserialise)
      |> Map.put(:action, :validate)

    assigns = process_rrule(socket, changeset)
    {:noreply, assigns}
  end

  def handle_event("save", %{"rrules" => rrules_params}, socket) do
    save_rrules(socket, socket.assigns.action, rrules_params)
  end

  defp save_rrules(socket, :edit, rrules_params) do
    rrules_deserialise = text_inputs_to_arrays(rrules_params)

    case Recurreces.update_rrules(socket.assigns.rrules, rrules_deserialise) do
      {:ok, rrules} ->
        notify_parent({:saved, rrules})

        {:noreply,
         socket
         |> put_flash(:info, "Rrules updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_rrules(socket, :new, rrules_params) do
    rrules_deserialise = text_inputs_to_arrays(rrules_params)

    case Recurreces.create_rrules(rrules_deserialise) do
      {:ok, rrules} ->
        notify_parent({:saved, rrules})

        {:noreply,
         socket
         |> put_flash(:info, "Rrules created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp process_rrule(socket, changeset) do
    if Enum.empty?(Map.get(changeset, :errors)) do
      data = get_dates(changeset)

      socket
      |> assign(:dates, Map.get(data, :dates))
      |> assign_form(add_rrule(changeset, Map.get(data, :rrule)))
    else
      socket
      |> assign_form(changeset)
    end
  end

  defp get_dates(changeset) do
    model =
      Enum.reduce(Rrules.rrule_keys(), %{}, fn k, acc ->
        Map.put(acc, k, Ecto.Changeset.get_field(changeset, k))
      end)

    ProcessRrule.process_data(model)
  end

  defp text_inputs_to_arrays(params) do
    Enum.reduce(
      [
        "by_hour",
        "by_minute",
        "by_second",
        "by_month",
        "by_month_day",
        "by_set_pos",
        "by_year_day",
        "by_week_no"
      ],
      params,
      fn k, acc -> Map.update!(acc, k, &deserialise_text_array/1) end
    )
  end

  defp add_rrule(%Ecto.Changeset{} = changeset, rrule) do
    changeset |> Map.put(:changes, Map.put(Map.get(changeset, :changes), :rrule, rrule))
  end

  defp deserialise_text_array(text) when is_nil(text), do: nil

  defp deserialise_text_array(text) do
    text
    |> String.replace(" ", "")
    |> String.split(",")
  end

  defp string_to_date(date) do
    {:ok, dateParsed} = NaiveDateTime.from_iso8601(date)
    Calendar.strftime(dateParsed, "%a, %B %d %Y")
  end

  defp serialise_array(param) when param == nil do
    param
  end

  defp serialise_array(param) do
    Enum.join(param, ", ")
  end
end
