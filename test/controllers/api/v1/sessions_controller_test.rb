require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @user = User.create!(name: "John", email: "john@example.com", password: "password123")
  end

  test "valid credentials return a token and the user" do
    login("john@example.com", "password123")

    assert_response :ok
    assert_predicate response.parsed_body["token"], :present?
    assert_equal "John", response.parsed_body.dig("user", "name")
  end

  test "email is matched case-insensitively" do
    login("JOHN@example.com", "password123")

    assert_response :ok
  end

  test "wrong password is unauthorized" do
    login("john@example.com", "wrong-password")

    assert_response :unauthorized
    assert_equal "Invalid email or password", response.parsed_body["message"]
  end

  test "unknown email gets the same response as a wrong password" do
    login("nobody@example.com", "whatever")

    assert_response :unauthorized
    assert_equal "Invalid email or password", response.parsed_body["message"]
  end

  test "too many login attempts are rate limited" do
    10.times { login("john@example.com", "wrong-password") }
    assert_response :unauthorized

    login("john@example.com", "wrong-password")
    assert_response :too_many_requests
  end

  private
    def login(email, password)
      post "/api/v1/login", params: { session: { email: email, password: password } }, as: :json
    end
end
