defmodule RecurrencesClientWeb.RrulesLive.Index do
  use RecurrencesClientWeb, :live_view

  alias RecurrencesClient.Recurreces
  alias RecurrencesClient.Recurreces.Rrules

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :rrules_collection, Recurreces.list_rrules())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Rrules")
    |> assign(:rrules, Recurreces.get_rrules!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Rrules")
    |> assign(:dates, [])
    |> assign(:rrules, %Rrules{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Rrules")
    |> assign(:dates, [])
    |> assign(:rrules, nil)
  end

  @impl true
  def handle_info({RecurrencesClientWeb.RrulesLive.FormComponent, {:saved, rrules}}, socket) do
    {:noreply, stream_insert(socket, :rrules_collection, rrules)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    rrules = Recurreces.get_rrules!(id)
    {:ok, _} = Recurreces.delete_rrules(rrules)

    {:noreply, stream_delete(socket, :rrules_collection, rrules)}
  end
end
