require "test_helper"

class Api::V1::MeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "John", email: "john@example.com", password: "password123")
  end

  test "requires a token" do
    get "/api/v1/me"

    assert_response :unauthorized
  end

  test "valid token returns the greeting" do
    get "/api/v1/me", headers: auth_header(@user.generate_token_for(:api_auth))

    assert_response :ok
    assert_equal "Welcome John", response.parsed_body["message"]
  end

  test "tampered token is unauthorized" do
    token = @user.generate_token_for(:api_auth)
    get "/api/v1/me", headers: auth_header(token.chop)

    assert_response :unauthorized
  end

  test "token stops working after the password changes" do
    token = @user.generate_token_for(:api_auth)
    @user.update!(password: "newpassword123")
    get "/api/v1/me", headers: auth_header(token)

    assert_response :unauthorized
  end

  private
    def auth_header(token)
      { "Authorization" => "Bearer #{token}" }
    end
end
