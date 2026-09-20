key =
  System.get_env("TYPESAFE_API_KEY") ||
    raise "TYPESAFE_API_KEY is required for the live example"

client =
  TypeSafeAPISDK.new_client(
    api_key: key,
    base_url: System.get_env("TYPESAFE_BASE_URL") || "https://api.typesafe.ai",
    model: System.get_env("TYPESAFE_DEFAULT_MODEL") || "jev-latest",
    retry: false
  )

{:ok, catalog} = TypeSafeAPISDK.list_models(client)
IO.puts("models=#{length(catalog.models)}")

{:ok, response} =
  TypeSafeAPISDK.system_one(
    client,
    "The customer says they were charged twice for the same invoice.",
    %{
      billing: TypeSafeAPISDK.noul(instructions: "Is this about billing?"),
      route:
        TypeSafeAPISDK.choice(
          %{"billing" => "Payments and invoices", "technical" => "Product behavior"},
          instructions: "Which team should review this?"
        )
    }
  )

IO.inspect(
  %{
    model: response.model,
    request_id: response.request_id,
    usage: response.usage,
    billing: response.answers["billing"].noul,
    route: response.answers["route"].choice
  },
  label: "TypeSafe response"
)
