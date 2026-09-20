defmodule TypeSafeAPISDK.TestSupport.ResponseHelpers do
  @moduledoc false

  def json_response(body, opts \\ []) do
    status = Keyword.get(opts, :status, 200)
    request_id = Keyword.get(opts, :request_id, "req_test")

    headers =
      opts
      |> Keyword.get(:headers, %{})
      |> Map.new(fn {key, value} -> {String.downcase(to_string(key)), to_string(value)} end)
      |> Map.put_new("content-type", "application/json")
      |> Map.put_new("x-typesafe-request-id", request_id)

    {:ok,
     %Pristine.Core.Response{
       status: status,
       body: Jason.encode!(body),
       headers: headers
     }}
  end

  def client(responder, opts \\ []) when is_function(responder, 1) do
    TypeSafeAPISDK.new_client(
      Keyword.merge(
        [
          api_key: "test-key",
          transport: TypeSafeAPISDK.TestSupport.Transport,
          transport_opts: [responder: responder],
          retry: false
        ],
        opts
      )
    )
  end
end
