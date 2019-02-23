defmodule SpaceWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:" <> room_id, _params, socket) do
    [x, y] = String.split(room_id, ",")
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    [topic, position] = String.split(socket.topic, ":")
    [x, y] = String.split(position, ",")
    {:ok, cached} = Cachex.get(:space, "room:#{x},#{y}")
    push(socket, "data_room", %{position: %{ x: x, y: y }, room: cached})
    {:noreply, socket}
  end

  def handle_in("claim_room", %{"body" => body}, socket) do
    [topic, position] = String.split(socket.topic, ":")
    [x, y] = String.split(position, ",")
    {:ok, cached} = Cachex.get(:space, "room:#{x},#{y}")
    {:ok, user} = Map.fetch(body, "user")

    case {x, y, cached} do
      {"0", "0", _} ->
        IO.puts("Can't claim root")
      {_, _, nil} ->
        IO.puts("Can claim")
        new_body = %{ claimed: true, user: user }
        Cachex.put!(:space, "room:#{x},#{y}", new_body)
        push(socket, "data_room", %{position: %{ x: x, y: y }, room: new_body})
      _ ->
        IO.puts("Can't claim")
    end
    {:noreply, socket}
  end

  def handle_in("authenticate", %{"body" => body}, socket) do
    {:noreply, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end

  def handle_in("new_room", %{"body" => body}, socket) do
    {:ok, position} = Map.fetch(body, "position")
    {:ok, x} = Map.fetch(position, "x")
    {:ok, y} = Map.fetch(position, "y")

    {:ok, cached} = Cachex.get(:space, "room:#{x},#{y}")
    push(socket, "data_room", %{position: position, room: cached})
    {:noreply, socket}
  end
end
