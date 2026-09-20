defmodule TypeSafeAPISDK.ErrorTest do
  use ExUnit.Case, async: true

  alias TypeSafeAPISDK.{Error, RetryPolicy}

  test "Retry-After milliseconds take precedence" do
    assert Error.parse_retry_after(%{"retry-after" => "10", "retry-after-ms" => "125"}) == 125
  end

  test "HTTP and transport retryability follows RetryPolicy" do
    policy = RetryPolicy.new!(http_statuses: [429, 503])
    assert Error.retryable?(%Error{type: :rate_limit, status: 429}, policy)
    assert Error.retryable?(%Error{type: :internal_server, status: 503}, policy)
    refute Error.retryable?(%Error{type: :bad_request, status: 400}, policy)
  end
end
