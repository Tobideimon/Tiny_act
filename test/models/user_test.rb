require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "creates a default room after signup" do
    user = create_user!

    assert_not_nil user.room
    assert_equal Room::GRID_WIDTH, user.room.width
    assert_equal Room::GRID_HEIGHT, user.room.height
  end

  test "validates avatar against the supported list" do
    user = create_user!

    user.avatar = "unknown"

    assert_not user.valid?
    assert_includes user.errors[:avatar], "is not included in the list"
  end
end
