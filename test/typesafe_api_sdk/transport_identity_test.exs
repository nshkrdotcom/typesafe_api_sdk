defmodule TypeSafeAPISDK.TransportIdentityTest do
  use ExUnit.Case, async: true

  import TypeSafeAPISDK.TestSupport.ResponseHelpers

  test "SDK identity/auth headers are owned by the client and deployment prefixes survive" do
    parent = self()

    responder = fn request ->
      send(parent, {:request, request})
      json_response(%{"models" => []})
    end

    client =
      client(
        responder,
        base_url: "https://example.test/provider",
        headers: %{"Authorization" => "Bearer attacker", "X-App" => "demo"}
      )

    assert {:ok, _} = TypeSafeAPISDK.list_models(client)
    assert_receive {:request, request}

    assert URI.parse(request.url).path == "/provider/v1/models"

    headers =
      Map.new(request.headers, fn {key, value} ->
        {String.downcase(to_string(key)), to_string(value)}
      end)

    assert headers["user-agent"] == "typesafe-api-sdk/0.1.0"
    assert headers["x-typesafe-sdk"] == "typesafe-api-sdk/0.1.0"
    assert headers["authorization"] == "Bearer test-key"
    assert headers["x-app"] == "demo"
  end
end
