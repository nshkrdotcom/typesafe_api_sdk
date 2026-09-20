defmodule TypeSafeAPISDK.LiveMatrixExample do
  @official_base_url "https://api.typesafe.ai"

  def run do
    official_key = required_env!("TYPESAFE_API_KEY")

    IO.puts("== official TypeSafe endpoint ==")
    run_endpoint(@official_base_url, official_key, System.get_env("TYPESAFE_LIVE_MODEL"))

    case System.get_env("TYPESAFE_LIVE_ALT_BASE_URL") do
      nil ->
        IO.puts("\n== alternate endpoint ==")

        IO.puts(
          "not configured; set TYPESAFE_LIVE_ALT_BASE_URL and TYPESAFE_LIVE_ALT_API_KEY to exercise it"
        )

      base_url ->
        IO.puts("\n== alternate TypeSafe-compatible endpoint ==")
        api_key = required_env!("TYPESAFE_LIVE_ALT_API_KEY")
        run_endpoint(base_url, api_key, System.get_env("TYPESAFE_LIVE_ALT_MODEL"))
    end
  end

  defp run_endpoint(base_url, api_key, requested_model) do
    discovery_client =
      TypeSafeAPISDK.new_client(
        api_key: api_key,
        base_url: base_url,
        model: requested_model || "jev-latest",
        retry: false,
        timeout_ms: 30_000
      )

    catalog = TypeSafeAPISDK.list_models!(discovery_client, retry: false, timeout_ms: 30_000)
    model = requested_model || first_model!(catalog)

    client =
      TypeSafeAPISDK.new_client(
        api_key: api_key,
        base_url: base_url,
        model: model,
        retry: [max_retries: 1, backoff_initial: 0, backoff_max: 0, backoff_jitter: 0],
        timeout: 30,
        headers: %{"X-TypeSafe-Live-Client" => "matrix-example"}
      )

    response =
      TypeSafeAPISDK.system_one!(
        client,
        "A customer reports a duplicate invoice charge and requests help today.",
        %{
          billing: TypeSafeAPISDK.noul(instructions: "Is this about billing?"),
          route:
            TypeSafeAPISDK.choice(
              %{"billing" => "Payments and invoices", "technical" => "Product behavior"},
              instructions: "Which team should review this?"
            ),
          urgency:
            TypeSafeAPISDK.score(
              ["can wait", "needs attention soon", "needs attention today"],
              instructions: "How urgent is this?"
            )
        },
        model: model,
        extra_body: %{"model" => model},
        retry: false,
        timeout_ms: 30_000,
        extra_headers: %{"X-TypeSafe-Live-Matrix" => "matrix-example"}
      )

    IO.inspect(
      %{
        endpoint: client.base_url,
        catalog_models: Enum.map(catalog.models, & &1.name),
        requested_model: model,
        observed_model: response.model,
        request_id: response.request_id,
        usage: response.usage,
        billing: response.answers["billing"].noul,
        route: response.answers["route"].choice,
        urgency: response.answers["urgency"].score
      },
      pretty: true
    )
  end

  defp first_model!(%{models: [%{name: name} | _]}) when is_binary(name), do: name
  defp first_model!(catalog), do: raise("model catalog was empty or malformed: #{inspect(catalog)}")

  defp required_env!(name) do
    case System.get_env(name) do
      value when is_binary(value) and byte_size(value) > 0 -> value
      _ -> raise "#{name} is required"
    end
  end
end

TypeSafeAPISDK.LiveMatrixExample.run()
