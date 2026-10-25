require "test_helper"

class CorsTest < ActionDispatch::IntegrationTest
  test "allows the configured origin" do
    options "/api/v1/me", headers: {
      "Origin" => "http://localhost:5173",
      "Access-Control-Request-Method" => "GET"
    }

    assert_equal "http://localhost:5173", response.headers["Access-Control-Allow-Origin"]
  end

  test "does not allow other origins" do
    options "/api/v1/me", headers: {
      "Origin" => "http://evil.com",
      "Access-Control-Request-Method" => "GET"
    }

    assert_nil response.headers["Access-Control-Allow-Origin"]
  end
end
