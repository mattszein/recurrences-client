defmodule RecurrencesClientWeb.RrulesLive.FormComponent do
  use RecurrencesClientWeb, :live_component

  alias RecurrencesClient.Recurreces
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
          <.input field={@form[:name]} type="text" label="Name" />
          <.input
            field={@form[:freq]}
            type="select"
            label="Freq"
            prompt="Choose a value"
            options={Ecto.Enum.values(RecurrencesClient.Recurreces.Rrules, :freq)}
          />
          <.input field={@form[:by_hour]} type="text" label="By Hour" pattern="[0-9.]+" />
          <.input field={@form[:by_minute]} type="text" label="By Minute" />
          <.input field={@form[:by_month]} type="text" label="By Month" />
          <.input field={@form[:by_month_day]} type="text" label="By Month Day" />
          <.input field={@form[:by_second]} type="text" label="By Second" />
          <.input field={@form[:by_set_pos]} type="text" label="By Set pos" />

         <.input
            field={@form[:by_week_day]}
            type="select"
            multiple
            label="By week day"
            options={Ecto.Enum.values(RecurrencesClient.Recurreces.Rrules, :by_week_day)}
          />
          <.input field={@form[:by_week_no]} type="text" label="By Week no" />
          <.input field={@form[:by_year_day]} type="text" label="By Year Day" />
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
          </.table>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{rrules: rrules} = assigns, socket) do
    changeset = Recurreces.change_rrules(rrules)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"rrules" => rrules_params}, socket) do
    # rrules_deserialise = %{
    #  rrules_params
    #  | "by_hour" => deserialise_text_array(Map.get(rrules_params, "by_hour"))
    # }
    rrules_deserialise = text_inputs_to_arrays(rrules_params)

    changeset =
      socket.assigns.rrules
      |> Recurreces.change_rrules(rrules_deserialise)
      |> Map.put(:action, :validate)

    assigns =
      if Enum.empty?(Map.get(changeset, :errors)) do
        data = ProcessRrule.process_data(parse_dates(Map.get(changeset, :changes)))

        socket
        |> assign(:dates, Map.get(data, :dates))
        |> assign_form(replace_array_with_param_text(changeset, rrules_params))
      else
        assign_form(socket, replace_array_with_param_text(changeset, rrules_params))
      end

    {:noreply, assigns}
  end

  def handle_event("save", %{"rrules" => rrules_params}, socket) do
    save_rrules(socket, socket.assigns.action, rrules_params)
  end

  defp save_rrules(socket, :edit, rrules_params) do
    case Recurreces.update_rrules(socket.assigns.rrules, rrules_params) do
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
    case Recurreces.create_rrules(rrules_params) do
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

  def parse_dates(change) do
    change
    |> Map.update!(:dt_start, &date_to_string/1)
    |> Map.update!(:until, &date_to_string/1)
    |> Map.update!(:freq, &Atom.to_string(&1))
    |> Map.update(:by_week_day, "", &atom_to_string_list(&1))
  end

  def text_inputs_to_arrays(params) do
    params
    |> Map.update!("by_hour", &deserialise_text_array/1)
    |> Map.update!("by_minute", &deserialise_text_array/1)
    |> Map.update!("by_second", &deserialise_text_array/1)
    |> Map.update!("by_month", &deserialise_text_array/1)
    |> Map.update!("by_month_day", &deserialise_text_array/1)
    |> Map.update!("by_set_pos", &deserialise_text_array/1)
  end

  def string_to_atom_map(map) do
    map |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  def atom_to_string_list(list) do
    list |> Enum.map(fn k -> Atom.to_string(k) end)
  end

  def replace_array_with_param_text(%Ecto.Changeset{} = changeset, params) do
    changeset |> Map.put(:changes, string_to_atom_map(params))
  end

  def deserialise_text_array(text) when is_nil(text), do: nil

  def deserialise_text_array(text) do
    text
    |> String.replace(" ", "")
    |> String.split(",")
  end

  def date_to_string(date) do
    NaiveDateTime.to_iso8601(date)
  end
end
