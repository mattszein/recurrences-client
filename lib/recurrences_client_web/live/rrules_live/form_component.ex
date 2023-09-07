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
          />
          <.input field={@form[:by_hour]} type="text" label="By Hour" value={input_value(@form, :by_hour) |> serialise_array} />
          <.input field={@form[:by_minute]} type="text" label="By Minute"  value={input_value(@form, :by_minute) |> serialise_array}/> 
          <.input field={@form[:by_month]} type="text" label="By Month" value={input_value(@form, :by_month) |> serialise_array}/>
          <.input field={@form[:by_month_day]} type="text" label="By Month Day" value={input_value(@form, :by_month_day) |> serialise_array} />
          <.input field={@form[:by_second]} type="text" label="By Second" value={input_value(@form, :by_second) |> serialise_array}/>
          <.input field={@form[:by_set_pos]} type="text" label="By Set pos" value={input_value(@form, :by_set_pos) |> serialise_array} />

         <.input
            field={@form[:by_week_day]}
            type="select"
            multiple
            label="By week day"
            options={[{"MO", "MO"}, {"TU","TU"}, {"WE","WE"}, {"TH","TH"}, {"FR", "FR"}, {"SA","SA"}, {"SU","SU"}]}
          />
          <.input field={@form[:by_week_no]} type="text" label="By Week no" value={input_value(@form, :by_week_no) |> serialise_array}/>
          <.input field={@form[:by_year_day]} type="text" label="By Year Day" value={input_value(@form, :by_year_day) |> serialise_array} />
          <.input field={@form[:count]} type="number" label="Count" />
          <.input field={@form[:dt_start]} type="datetime-local" label="Dt start" />
          <.input field={@form[:interval]} type="number" label="Interval" />
          <.input field={@form[:until]} type="datetime-local" label="Until" />
          <.input field={@form[:week_start]} type="number" label="Week start" />

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
