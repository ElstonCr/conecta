require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "name must be present" do
    user = User.new
    user.valid?

    assert_includes user.errors[:name], "can't be blank"
  end

  test "email must be present" do
    user = User.new
    user.valid?

    assert_includes user.errors[:email], "can't be blank"
  end

  test "email must be unique" do
    User.create!(
      name: "John",
      email: "john@example.com",
      password: "password"
    )

    duplicate_user = User.new(
      name: "Jane",
      email: "john@example.com",
      password: "password"
    )

    duplicate_user.valid?

    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "password must be present" do
    user = User.new(
      name: "John",
      email: "john@example.com"
    )

    user.valid?

    assert_includes user.errors[:password], "can't be blank"
  end

  test "password is stored as a digest" do
    user = User.create!(
      name: "John",
      email: "john@example.com",
      password: "secret123"
    )

    assert_not_equal "secret123", user.password_digest
    assert user.authenticate("secret123")
  end
end
