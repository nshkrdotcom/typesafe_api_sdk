key =
  System.get_env("TYPESAFE_API_KEY") ||
    raise "TYPESAFE_API_KEY is required for the live example"

base_url = System.get_env("TYPESAFE_BASE_URL") || "https://api.typesafe.ai"
requested_model = System.get_env("TYPESAFE_DEFAULT_MODEL") || "jev-latest"

client =
  TypeSafeAPISDK.new_client(
    api_key: key,
    base_url: base_url,
    model: requested_model,
    timeout_ms: 30_000,
    retry: false,
    headers: %{"X-TypeSafe-Live-Example" => "0.1.0"}
  )

catalog =
  TypeSafeAPISDK.list_models!(
    client,
    retry: false,
    timeout_ms: 30_000,
    extra_headers: %{"X-TypeSafe-Live-Matrix" => "example-models"}
  )

IO.puts("endpoint=#{client.base_url}")
IO.puts("models=#{length(catalog.models)}")
IO.puts("requested_model=#{requested_model}")

response =
  TypeSafeAPISDK.system_one!(
    client,
    "The customer says they were charged twice for the same invoice and need help today.",
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
    model: requested_model,
    retry: false,
    timeout: 30,
    extra_headers: %{"X-TypeSafe-Live-Matrix" => "example-system-one"}
  )

IO.inspect(
  %{
    model: response.model,
    request_id: response.request_id,
    usage: response.usage,
    elapsed_ms: response.elapsed_ms,
    retries: response.retries,
    billing: response.answers["billing"].noul,
    route: response.answers["route"].choice,
    route_confidence: response.answers["route"].confidence,
    urgency: response.answers["urgency"].score,
    urgency_confidence: response.answers["urgency"].confidence
  },
  label: "TypeSafe response"
)
