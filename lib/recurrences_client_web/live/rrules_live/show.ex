defmodule RecurrencesClientWeb.RrulesLive.Show do
  use RecurrencesClientWeb, :live_view

  alias RecurrencesClient.Recurreces

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:rrules, Recurreces.get_rrules!(id))}
  end

  defp page_title(:show), do: "Show Rrules"
  defp page_title(:edit), do: "Edit Rrules"
end
