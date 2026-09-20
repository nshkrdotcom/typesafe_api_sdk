defmodule TypeSafeAPISDK.ClientConfigurationTest do
  use ExUnit.Case, async: true

  alias TypeSafeAPISDK.{Client, Error}

  test "default provider configuration is TypeSafe-specific" do
    client = Client.new(api_key: "secret")
    assert client.base_url == "https://api.typesafe.ai"
    assert client.default_model == "jev-latest"
    assert client.timeout_ms == 10_000
  end

  test "base URL preserves a deployment path prefix" do
    client = Client.new(api_key: "secret", base_url: "https://example.test/proxy/")
    assert client.base_url == "https://example.test/proxy"
  end

  test "invalid base URLs fail locally" do
    for value <- [
          "",
          "ftp://example.test",
          "https://user:pass@example.test",
          "https://example.test/?q=1"
        ] do
      assert_raise Error, fn -> Client.new(api_key: "secret", base_url: value) end
    end
  end

  test "API key is required" do
    assert_raise Error, fn -> Client.new(api_key: "   ") end
  end

  test "client-level timeout accepts seconds or milliseconds" do
    assert Client.new(api_key: "secret", timeout: 1.5).timeout_ms == 1500
    assert Client.new(api_key: "secret", timeout_ms: 250).timeout_ms == 250
  end
end
