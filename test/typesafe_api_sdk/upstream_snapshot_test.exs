defmodule TypeSafeAPISDK.UpstreamSnapshotTest do
  use ExUnit.Case, async: true

  test "committed TypeSafe OpenAPI snapshot contains the reviewed provider surface" do
    document = File.read!("priv/upstream/openapi.json") |> Jason.decode!()

    assert get_in(document, ["paths", "/v1/systemone", "post"])
    assert get_in(document, ["paths", "/v1/models", "get"])

    required = ~w(
      ChoiceAnswer ChoiceQuestion ModelMetadata ModelMetadataList
      NoulAnswer NoulCriteria NoulQuestion ScoreAnswer ScoreQuestion
      SystemOneRequest SystemOneResponse Usage
    )

    schemas = get_in(document, ["components", "schemas"])
    assert Enum.all?(required, &Map.has_key?(schemas, &1))
  end
end
