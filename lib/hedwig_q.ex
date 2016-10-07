defmodule Hedwig.Adapters.Q do
  @moduledoc """
  Hedwig adapter that communicates to the instant messenger via Chatbot interface.
  """

  use Hedwig.Adapter
  require Logger

  @doc false
  def init({robot, opts}) do
    :global.register_name("adapter_q", self())
    state = %{
      robot: robot,
      routes: nil
    }

    {:ok, state}
  end

  @doc false
  def handle_cast({:emote, msg}, state) do
    Logger.debug "EMOTING > #{inspect msg}"
    Kernal.send(routes[ref], msg)
    Process.demonitor(routes[ref])
    # send_message(msg.user, msg.text, state)
    {:noreply, %{state | routes: Map.delete(routes, ref)}}
  end

  @doc false
  def handle_cast({:reply, msg}, state) do
    Logger.debug "REPLYING > #{inspect msg}"
    Kernal.send(routes[ref], msg)
    Process.demonitor(routes[ref])
    # send_message(msg.user, msg.text, state)
    {:noreply, %{state | routes: Map.delete(routes, ref)}}
  end

  @doc false
  def handle_cast({:send, msg}, %{routes: routes} = state) do
    Logger.debug("SENDING > #{inspect msg}")
    Kernal.send(routes[ref], msg)
    Process.demonitor(routes[ref])
    # send_message(msg.user, msg.text, state)
    {:noreply, %{state | routes: Map.delete(routes, ref)}}
  end

  defp send_message(user, body, state) do
    Logger.info "Sending #{body} to #{user}"
  end

  @doc """
  Sends the Q request body from the listening server to the robot
  with the specified `name`. `req_body` is assumed to be the post
  body string or a map with keys `"From"` and '"Body"`.
  """
  @spec handle_message(String.t, String.t | Map.t) :: {:error, :not_found} | :ok
  def handle_message(name, req_body) do
    case :global.whereis_name(name) do
      :undefined ->
        Logger.error("Robot named #{name} not found")
        {:error, :not_found}
      
      robot ->
        msg = parse_message(req_body)
        Hedwig.Robot.handle_message(robot, msg)
        :ok
    end
  end

  def handle_info({:message, pid, body}, %{robot: robot, routes: routes} = state) do
    Logger.debug "RECEIVED > #{inspect state}"
    msg = parse_message(body)
    msg = %{msg | robot: robot}
    ref = Process.monitor
    Hedwig.Robot.handle_in(robot, msg)
    {:noreply, %{state | routes: Map.put(routes, msg_ref, {ref, pid})}
  end


  defp parse_message(body) when is_binary(body) do
    data = Poison.decode!(body)
    Logger.debug "INCOMING > #{inspect data}"
    build_message(data)
  end

  defp build_message(%{"from" => user, "message" => text}) do
    %Hedwig.Message {
      ref: make_ref(),
      text: text,
      type: "chat",
      user: %Hedwig.User {
        name: user
      }
    }
  end
end
