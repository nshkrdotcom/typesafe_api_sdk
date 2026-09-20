defmodule TypeSafeAPISDK.LiveTest do
  use ExUnit.Case, async: false

  @moduletag :live

  test "real TypeSafe model list and System One request" do
    key = System.fetch_env!("TYPESAFE_API_KEY")
    client = TypeSafeAPISDK.new_client(api_key: key, retry: false)

    assert {:ok, models} = TypeSafeAPISDK.list_models(client)
    assert models.models != []

    assert {:ok, response} =
             TypeSafeAPISDK.system_one(
               client,
               "A customer asks where to find an invoice.",
               %{billing: TypeSafeAPISDK.noul(instructions: "Is this about billing?")}
             )

    assert is_binary(response.model)
    assert %{noul: probability} = response.answers["billing"]
    assert is_number(probability) and probability >= 0 and probability <= 1
  end
end
