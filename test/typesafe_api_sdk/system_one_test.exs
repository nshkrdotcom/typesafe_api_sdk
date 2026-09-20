defmodule TypeSafeAPISDK.SystemOneTest do
  use ExUnit.Case, async: true

  import TypeSafeAPISDK.TestSupport.ResponseHelpers

  alias TypeSafeAPISDK.{ChoiceAnswer, NoulAnswer, ScoreAnswer}

  test "POST /v1/systemone uses the configured model and decodes all known answer types" do
    parent = self()

    responder = fn request ->
      send(parent, {:request, request})

      json_response(%{
        "model" => "jev-test",
        "usage" => %{"input_tokens" => 11, "output_tokens" => 3},
        "answers" => %{
          "yes" => %{"type" => "noul", "noul" => 0.9},
          "route" => %{
            "type" => "choice",
            "choice" => "billing",
            "confidence" => 0.8,
            "probabilities" => %{"billing" => 0.8, "technical" => 0.2}
          },
          "severity" => %{
            "type" => "score",
            "score" => 1.25,
            "confidence" => 0.7,
            "legend" => %{"0" => "low", "1" => "medium", "2" => "high"},
            "probabilities" => %{"0" => 0.1, "1" => 0.55, "2" => 0.35}
          }
        }
      })
    end

    client = client(responder, model: "jev-test")

    questions = %{
      yes: TypeSafeAPISDK.noul(instructions: "Is this about billing?"),
      route: TypeSafeAPISDK.choice(%{"billing" => nil, "technical" => nil}),
      severity: TypeSafeAPISDK.score(["low", "medium", "high"])
    }

    assert {:ok, response} = TypeSafeAPISDK.system_one(client, "hello", questions)
    assert %NoulAnswer{noul: 0.9, id: "yes"} = response.answers["yes"]
    assert %ChoiceAnswer{choice: "billing", id: "route"} = response.answers["route"]
    assert %ScoreAnswer{score: 1.25, id: "severity"} = response.answers["severity"]
    assert response.usage.input_tokens == 11
    assert response.request_id == "req_test"

    assert_receive {:request, request}
    assert URI.parse(request.url).path == "/v1/systemone"
    payload = request.body |> IO.iodata_to_binary() |> Jason.decode!()
    assert payload["model"] == "jev-test"
    assert Map.keys(payload["questions"]) |> Enum.sort() == ["route", "severity", "yes"]
  end

  test "wire-level extra_body keeps the provider escape hatch" do
    parent = self()

    responder = fn request ->
      send(parent, {:request, request})

      json_response(%{
        "model" => "override-model",
        "usage" => %{"input_tokens" => 1, "output_tokens" => 0},
        "answers" => %{"q" => %{"type" => "noul", "noul" => 1.0}}
      })
    end

    client = client(responder, model: "default-model")

    assert {:ok, _} =
             TypeSafeAPISDK.system_one(
               client,
               "state",
               %{q: TypeSafeAPISDK.noul(instructions: "Q?")},
               extra_body: %{"model" => "override-model"}
             )

    assert_receive {:request, request}
    payload = request.body |> IO.iodata_to_binary() |> Jason.decode!()
    assert payload["model"] == "override-model"
  end

  test "future answer types remain available in unknown_answers" do
    responder = fn _request ->
      json_response(%{
        "model" => "future",
        "usage" => %{"input_tokens" => 1, "output_tokens" => 0},
        "answers" => %{"x" => %{"type" => "future-kind", "value" => 1}}
      })
    end

    client = client(responder, model: "future")

    assert {:ok, response} =
             TypeSafeAPISDK.system_one(client, "state", %{x: %{"type" => "future-question"}})

    assert response.answers == %{}
    assert response.unknown_answers["x"]["type"] == "future-kind"
  end
end
