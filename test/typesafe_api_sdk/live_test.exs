defmodule TypeSafeAPISDK.LiveTest do
  use ExUnit.Case, async: false

  alias TypeSafeAPISDK.{ChoiceAnswer, NoulAnswer, ScoreAnswer, SystemOneResponse}

  @moduletag :live
  @moduletag timeout: 120_000
  @official_base_url "https://api.typesafe.ai"

  @tag live_official: true
  test "official defaults exercise models plus Noul, Choice, and Score through the tuple API" do
    client = TypeSafeAPISDK.new_client(api_key: official_key!(), retry: false)

    assert client.base_url == @official_base_url
    assert client.default_model == "jev-latest"

    assert {:ok, catalog} = TypeSafeAPISDK.list_models(client, retry: false, timeout_ms: 30_000)
    assert catalog.models != []
    assert is_binary(catalog.request_id)
    assert catalog.raw_http_response.status == 200

    assert {:ok, response} =
             TypeSafeAPISDK.system_one(
               client,
               "A customer says they were charged twice and need help today.",
               live_questions(),
               retry: false,
               timeout_ms: 30_000,
               extra_headers: %{"X-TypeSafe-Live-Matrix" => "official-defaults"}
             )

    assert_live_response!(response)
  end

  @tag live_official: true
  test "explicit client configuration plus bang APIs and per-call controls work on the official service" do
    key = official_key!()

    catalog_client =
      TypeSafeAPISDK.new_client(
        api_key: key,
        base_url: @official_base_url,
        model: "jev-latest",
        timeout: 30,
        retry: false,
        headers: %{"X-TypeSafe-Live-Client" => "explicit"}
      )

    catalog =
      TypeSafeAPISDK.list_models!(
        catalog_client,
        retry: false,
        timeout_ms: 30_000,
        extra_headers: %{"X-TypeSafe-Live-Matrix" => "official-explicit-models"}
      )

    selected_model = requested_or_first_model!(catalog)

    client =
      TypeSafeAPISDK.new_client(
        api_key: key,
        base_url: @official_base_url,
        model: selected_model,
        timeout_ms: 30_000,
        retry: [max_retries: 1, backoff_initial: 0, backoff_max: 0, backoff_jitter: 0],
        headers: %{"X-TypeSafe-Live-Client" => "explicit"}
      )

    response =
      TypeSafeAPISDK.system_one!(
        client,
        "A customer reports a duplicate invoice charge and asks which team should respond.",
        live_questions(),
        model: selected_model,
        extra_body: %{"model" => selected_model},
        retry: false,
        timeout: 30,
        extra_headers: %{"X-TypeSafe-Live-Matrix" => "official-explicit-system-one"}
      )

    assert_live_response!(response)
    assert client.base_url == @official_base_url
    assert client.default_model == selected_model
  end

  if System.get_env("TYPESAFE_LIVE_ALT_BASE_URL") do
    @tag live_alt: true
    test "explicit alternate TypeSafe-compatible endpoint/key/model exercises both operations" do
      base_url = System.fetch_env!("TYPESAFE_LIVE_ALT_BASE_URL")
      api_key = System.fetch_env!("TYPESAFE_LIVE_ALT_API_KEY")

      discovery_client =
        TypeSafeAPISDK.new_client(
          api_key: api_key,
          base_url: base_url,
          model: "unused-during-model-discovery",
          retry: false,
          timeout_ms: 30_000
        )

      catalog = TypeSafeAPISDK.list_models!(discovery_client, retry: false, timeout_ms: 30_000)
      selected_model = alternate_or_first_model!(catalog)

      client =
        TypeSafeAPISDK.new_client(
          api_key: api_key,
          base_url: base_url,
          model: selected_model,
          retry: false,
          timeout_ms: 30_000,
          headers: %{"X-TypeSafe-Live-Client" => "alternate"}
        )

      response =
        TypeSafeAPISDK.system_one!(
          client,
          "A customer reports a duplicate charge.",
          live_questions(),
          model: selected_model,
          retry: false,
          timeout_ms: 30_000,
          extra_headers: %{"X-TypeSafe-Live-Matrix" => "alternate"}
        )

      assert_live_response!(response)
      assert client.base_url == String.trim_trailing(String.trim(base_url), "/")
      assert client.default_model == selected_model
    end
  end

  defp official_key!, do: System.fetch_env!("TYPESAFE_API_KEY")

  defp requested_or_first_model!(catalog) do
    requested = System.get_env("TYPESAFE_LIVE_MODEL")

    if requested && String.trim(requested) != "" do
      String.trim(requested)
    else
      catalog.models |> List.first() |> model_name!()
    end
  end

  if System.get_env("TYPESAFE_LIVE_ALT_BASE_URL") do
    defp alternate_or_first_model!(catalog) do
      requested = System.get_env("TYPESAFE_LIVE_ALT_MODEL")

      if requested && String.trim(requested) != "" do
        String.trim(requested)
      else
        catalog.models |> List.first() |> model_name!()
      end
    end
  end

  defp model_name!(%{name: name}) when is_binary(name) and byte_size(name) > 0, do: name

  defp model_name!(other),
    do: flunk("model catalog did not contain a usable model: #{inspect(other)}")

  defp live_questions do
    %{
      billing: TypeSafeAPISDK.noul(instructions: "Is this request about billing?"),
      route:
        TypeSafeAPISDK.choice(
          %{
            "billing" => "Payments, invoices, duplicate charges, and refunds",
            "technical" => "Product behavior, bugs, and outages"
          },
          instructions: "Which team should review this request?"
        ),
      urgency:
        TypeSafeAPISDK.score(
          ["can wait", "needs attention soon", "needs attention today"],
          instructions: "How urgent is this request?"
        )
    }
  end

  defp assert_live_response!(response) do
    assert_response_metadata!(response)
    assert_usage!(response)
    assert_noul_answer!(response)
    assert_choice_answer!(response)
    assert_score_answer!(response)
    assert_response_helpers!(response)
  end

  defp assert_response_metadata!(response) do
    assert %SystemOneResponse{} = response
    assert is_binary(response.model) and byte_size(response.model) > 0
    assert is_binary(response.request_id) and byte_size(response.request_id) > 0
    assert response.raw_http_response.status == 200
    assert is_number(response.elapsed_ms) and response.elapsed_ms >= 0
    assert is_integer(response.retries) and response.retries >= 0
  end

  defp assert_usage!(response) do
    assert is_integer(response.usage.input_tokens) and response.usage.input_tokens >= 0
    assert is_integer(response.usage.output_tokens) and response.usage.output_tokens >= 0
  end

  defp assert_noul_answer!(response) do
    assert %NoulAnswer{noul: noul} = response.answers["billing"]
    assert is_number(noul) and noul >= 0 and noul <= 1
  end

  defp assert_choice_answer!(response) do
    assert %ChoiceAnswer{
             choice: choice,
             confidence: confidence,
             probabilities: probabilities
           } = response.answers["route"]

    assert choice in ["billing", "technical"]
    assert is_number(confidence) and confidence >= 0 and confidence <= 1
    assert probabilities |> Map.keys() |> Enum.sort() == ["billing", "technical"]
  end

  defp assert_score_answer!(response) do
    assert %ScoreAnswer{
             score: score,
             confidence: confidence,
             legend: legend,
             probabilities: probabilities
           } = response.answers["urgency"]

    assert is_number(score)
    assert is_number(confidence) and confidence >= 0 and confidence <= 1
    assert legend |> Map.keys() |> Enum.sort() == [0, 1, 2]
    assert probabilities |> Map.keys() |> Enum.sort() == [0, 1, 2]
  end

  defp assert_response_helpers!(response) do
    assert Map.keys(SystemOneResponse.nouls(response)) == ["billing"]
    assert Map.keys(SystemOneResponse.choices(response)) == ["route"]
    assert Map.keys(SystemOneResponse.scores(response)) == ["urgency"]
    assert SystemOneResponse.request_id!(response) == response.request_id
    assert SystemOneResponse.raw_http_response!(response).status == 200
  end
end
