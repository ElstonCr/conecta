require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "signup creates a user and returns a token" do
    assert_difference "User.count", 1 do
      post "/api/v1/users",
           params: { user: { name: "Jane", email: "new@example.com", password: "password123" } },
           as: :json
    end

    assert_response :created
    assert_predicate response.parsed_body["token"], :present?
    assert_nil response.parsed_body["password_digest"]
  end

  test "signup with a duplicate email is unprocessable" do
    post "/api/v1/users",
         params: { user: { name: "Jane", email: users(:one).email, password: "password123" } },
         as: :json

    assert_response :unprocessable_entity
  end
end
