defmodule TypeSafeAPISDK.ModelsTest do
  use ExUnit.Case, async: true

  import TypeSafeAPISDK.TestSupport.ResponseHelpers

  test "GET /v1/models decodes TypeSafe model metadata" do
    parent = self()

    responder = fn request ->
      send(parent, {:request, request})

      json_response(%{
        "models" => [
          %{"name" => "jev-test", "description" => "fixture", "release_date" => "2026-09-19"}
        ]
      })
    end

    client = client(responder)
    assert {:ok, response} = TypeSafeAPISDK.list_models(client)

    assert [%{name: "jev-test", description: "fixture", release_date: "2026-09-19"}] =
             response.models

    assert response.request_id == "req_test"

    assert_receive {:request, request}
    assert URI.parse(request.url).path == "/v1/models"
  end
end
