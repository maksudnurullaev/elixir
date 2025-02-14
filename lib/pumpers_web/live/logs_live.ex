defmodule PumpersWeb.LogsLive do
  use PumpersWeb, :live_view
  alias Pumpers.Accounts.Helper
  alias Pumpers.LogsHelper
  import PumpersWeb.MyComponents

  def render(assigns) do
    ~H"""
    <%= if @details do %>
      <.header>
        <.button_small phx-click="hide_detail" class="ml-2">
          <span aria-hidden="true">&larr;</span>back
        </.button_small>
        Request headers
      </.header>
      <.table id="details" rows={@details}>
        <:col :let={detail} label="Name">{detail.field}</:col>
        <:col :let={detail} label="Value">
          {detail.value}
        </:col>
      </.table>
    <% else %>
      <.header>
        Logs
      </.header>

      <.form for={@toolbar} phx-submit="set_toolbar">
        <ul class="flex">
          <li class="mr-6">
            <.input
              id="logs_page_number_id"
              name="page_size"
              type="select"
              value={@toolbar["page"]}
              options={1..10}
            />
          </li>
          <li class="mr-6">
            <.input
              id="logs_page_size_id"
              name="page_size"
              type="select"
              value={@toolbar["page_size"]}
              options={[25, 50, 100]}
            />
          </li>
          <li class="mr-6">
            <.input
              value={@toolbar["search_text"]}
              name="search_text"
              type="search"
              placeholder="search text"
            />
          </li>
          <li class="mr-6">
            <.button data-tooltip-target="tooltip-default" class="mt-2 bg-blue-600 hover:bg-sky-500">
              Search
            </.button>
            <span class="ml-1 cursor-pointer" phx-click={JS.push("update_logs")}>
              <.icon name="hero-arrow-path" class="ml-2 w-3 h-3 spin cursor-hand" />
            </span>
          </li>
        </ul>
      </.form>

      <.table
        id="logs"
        rows={@logs}
        row_click={&JS.push("get_request_headers", value: %{oid: &1.oid})}
      >
        <:col :let={log} label="#ID">{log.id}</:col>
        <:col :let={log} label="[HOST]:[METHOD]:[PATH]">{log.value}</:col>
      </.table>
    <% end %>
    """
  end

  # def hide_modal(js \\ %JS{}) do
  #   js
  #   |> JS.hide(transition: "fade-out", to: "#modal")
  #   |> JS.hide(transition: "fade-out-scale", to: "#modal-content")
  # end

  def mount(_params, _session, socket) do
    toolbar = %{
      "page" => 1,
      "pages" => 1,
      "page_size" => 25,
      "search_text" => nil
    }

    logs = LogsHelper.get_logs(toolbar)

    form = [
      logs: logs,
      details: nil,
      toolbar: toolbar
    ]

    {:ok, assign(socket, form)}
  end

  def handle_event("set_toolbar", params, socket) do
    toolbar = Map.merge(socket.assigns[:toolbar], params)

    if Map.equal?(socket.assigns[:toolbar], toolbar) do
      put_flash(socket, :info, "No changes!")
      {:noreply, socket}
    else
      logs = LogsHelper.get_logs(toolbar)
      {:noreply, update(socket, :toolbar, &(&1 = toolbar)) |> update(:logs, &(&1 = logs))}
    end

    # IO.puts("XXX: #{inspect(toolbar)}")
    # # logs = LogsHelper.get_logs(params)

    # # {:noreply,
    # #  update(socket, :toolbar, &(&1 = params))
    # #  |> update(:logs, &(&1 = logs))}
    # {:noreply, socket}
  end

  def handle_event("update_logs", _params, socket) do
    # logs = LogsHelper.get_log_by_name()
    # {:noreply, update(socket, :logs, &(&1 = logs))}
    {:noreply, socket}
  end

  def handle_event("hide_detail", _params, socket) do
    {:noreply, update(socket, :details, &(&1 = nil))}
  end

  def handle_event(
        "get_request_headers",
        %{"oid" => oid},
        socket
      ) do
    current_user = socket.assigns[:current_user]

    if Helper.user_is_valid_by_update_at?(current_user) do
      details = LogsHelper.get_log_details(oid)
      {:noreply, update(socket, :details, &(&1 = details))}
    else
      socket = put_flash(socket, :error, "User does not have proper rights!")
      {:noreply, redirect(socket, to: ~p"/")}
    end
  end
end
