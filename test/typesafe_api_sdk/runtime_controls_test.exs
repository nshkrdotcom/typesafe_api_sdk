defmodule TypeSafeAPISDK.RuntimeControlsTest do
  use ExUnit.Case, async: true

  import TypeSafeAPISDK.TestSupport.ResponseHelpers

  alias TypeSafeAPISDK.{Error, RuntimeCapabilities}

  test "per-call headers are forwarded while protected headers remain SDK-owned" do
    parent = self()

    responder = fn request ->
      send(parent, {:request, request})
      json_response(%{"models" => []})
    end

    client = client(responder)

    assert {:ok, _} =
             TypeSafeAPISDK.list_models(
               client,
               retry: false,
               timeout_ms: 500,
               extra_headers: %{
                 "Authorization" => "Bearer attacker",
                 "X-TypeSafe-SDK" => "attacker-sdk",
                 "X-Trace-ID" => "trace-live-matrix"
               }
             )

    assert_receive {:request, request}

    headers =
      Map.new(request.headers, fn {key, value} ->
        {String.downcase(to_string(key)), to_string(value)}
      end)

    assert headers["authorization"] == "Bearer test-key"
    assert headers["x-typesafe-sdk"] == "typesafe-api-sdk/0.1.0"
    assert headers["x-trace-id"] == "trace-live-matrix"
  end

  test "pre-cancelled Pristine token is forwarded and normalized without transport egress" do
    responder = fn _request ->
      flunk("a pre-cancelled request must not reach the responder")
    end

    client =
      TypeSafeAPISDK.new_client(
        api_key: "test-key",
        transport: TypeSafeAPISDK.TestSupport.CancelTransport,
        transport_opts: [responder: responder],
        retry: false
      )

    cancellation = Pristine.Cancellation.new()
    :ok = Pristine.Cancellation.cancel(cancellation)

    assert {:error, %Error{type: :cancelled}} =
             TypeSafeAPISDK.list_models(client, cancellation: cancellation, retry: false)
  end

  test "Pristine executes the configured TypeSafe retry policy on a retryable status" do
    {:ok, attempts} = Agent.start_link(fn -> 0 end)

    responder = fn _request ->
      attempt = Agent.get_and_update(attempts, fn count -> {count + 1, count + 1} end)

      case attempt do
        1 -> json_response(%{"error" => %{"message" => "try again"}}, status: 529)
        2 -> json_response(%{"models" => []})
      end
    end

    client =
      client(
        responder,
        retry: [max_retries: 1, backoff_initial: 0, backoff_max: 0, backoff_jitter: 0]
      )

    assert {:ok, _} = TypeSafeAPISDK.list_models(client)
    assert Agent.get(attempts, & &1) == 2
  end

  test "runtime capability reporting stays fail-closed" do
    client = client(fn _request -> json_response(%{"models" => []}) end)
    report = RuntimeCapabilities.report(client)

    assert report.assurance == :pristine_transport_contract
    assert is_binary(report.transport)
    assert is_map(report.runtime)

    for capability <- RuntimeCapabilities.names() do
      assert get_in(report, [:runtime, capability, :status]) in [
               :supported,
               :unsupported,
               :unverified
             ]
    end
  end
end
