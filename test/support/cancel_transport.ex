defmodule TypeSafeAPISDK.TestSupport.CancelTransport do
  @moduledoc false
  @behaviour Pristine.Ports.Transport

  import Kernel, except: [send: 2]

  alias Pristine.Cancellation

  @impl true
  def capabilities(_context) do
    %{
      unary_cancellation: :supported,
      cancellation_cleanup: :supported
    }
  end

  @impl true
  def send(request, context) do
    responder = Keyword.fetch!(context.transport_opts, :responder)
    responder.(request)
  end

  @impl true
  def send_cancelable(request, context, cancellation) do
    {:ok, cancellation} = Cancellation.validate(cancellation)

    if Cancellation.cancelled?(cancellation) do
      {:error, Pristine.Error.cancelled_error()}
    else
      send(request, context)
    end
  end
end
