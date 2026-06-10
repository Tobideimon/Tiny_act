require "test_helper"

class RoomLikeTest < ActiveSupport::TestCase
  test "is unique for the same user and room" do
    user = create_user!
    room = create_user!.room

    RoomLike.create!(user: user, room: room)
    duplicate = RoomLike.new(user: user, room: room)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end
