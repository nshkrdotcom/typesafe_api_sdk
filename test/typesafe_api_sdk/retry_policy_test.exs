defmodule TypeSafeAPISDK.RetryPolicyTest do
  use ExUnit.Case, async: true

  alias TypeSafeAPISDK.RetryPolicy

  test "default retry policy retains TypeSafe status behavior" do
    policy = RetryPolicy.new!()
    assert policy.max_retries == 2
    assert MapSet.member?(policy.http_statuses, 429)
    assert Enum.all?(500..599, &MapSet.member?(policy.http_statuses, &1))
  end

  test "per-call override merges with the client policy" do
    base = RetryPolicy.new!(max_retries: 4, backoff_max: 8.0)
    merged = RetryPolicy.merge!(base, max_retries: 1)
    assert merged.max_retries == 1
    assert merged.backoff_max == 8.0
  end
end
