require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email is normalized" do
    user = User.new(email: "  John@Example.COM ")

    assert_equal "john@example.com", user.email
  end

  test "email uniqueness ignores case" do
    User.create!(name: "John", email: "john@example.com", password: "password123")
    duplicate = User.new(name: "Jane", email: "JOHN@example.com", password: "password123")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "password must be at least 8 characters" do
    user = User.new(name: "John", email: "john@example.com", password: "short")
    user.valid?

    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "user can be updated without re-entering the password" do
    assert users(:one).update(name: "New name")
  end

  test "api auth token finds the user" do
    user = users(:one)
    token = user.generate_token_for(:api_auth)

    assert_equal user, User.find_by_token_for(:api_auth, token)
  end

  test "api auth token is rejected after the password changes" do
    user = users(:one)
    token = user.generate_token_for(:api_auth)
    user.update!(password: "newpassword123")

    assert_nil User.find_by_token_for(:api_auth, token)
  end

  test "api auth token expires after one day" do
    user = users(:one)
    token = user.generate_token_for(:api_auth)

    travel_to 2.days.from_now do
      assert_nil User.find_by_token_for(:api_auth, token)
    end
  end

  test "api auth token is rejected for a different purpose" do
    token = users(:one).generate_token_for(:api_auth)

    assert_nil User.find_by_token_for(:password_reset, token)
  end

  test "api auth token can be generated for a user without a password digest" do
    user = users(:one)
    user.update_column(:password_digest, nil)

    assert_predicate user.generate_token_for(:api_auth), :present?
  end
end
