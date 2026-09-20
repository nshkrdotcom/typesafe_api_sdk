defmodule TypeSafeAPISDK.ReleaseConsistencyTest do
  use ExUnit.Case, async: true

  test "package identity is consistently 0.1.0" do
    assert TypeSafeAPISDK.version() == "0.1.0"
    assert Mix.Project.config()[:version] == "0.1.0"
    assert Mix.Project.config()[:app] == :typesafe_api_sdk
    assert Mix.Project.config()[:docs][:source_ref] == "v0.1.0"
    assert File.read!("README.md") =~ ~s({:typesafe_api_sdk, "~> 0.1.0"})
    assert File.read!("CHANGELOG.md") =~ "## [0.1.0] - 2026-09-19"
  end

  test "semantic SDK subsystems are not present" do
    refute File.exists?("lib/typesafe_api_sdk/evaluation.ex")
    refute File.exists?("lib/typesafe_api_sdk/prepared.ex")
    refute File.exists?("lib/typesafe_api_sdk/batch.ex")
    refute File.exists?("lib/typesafe_api_sdk/otp/server.ex")
    refute File.exists?("lib/typesafe_api_sdk/telemetry.ex")
    refute File.exists?("lib/typesafe_api_sdk/test.ex")
  end
end
