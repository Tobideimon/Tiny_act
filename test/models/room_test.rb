require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "ensure_default_size normalizes room dimensions" do
    room = create_user!.room
    room.update!(width: 2, height: 3)

    room.ensure_default_size!

    assert_equal Room::GRID_WIDTH, room.width
    assert_equal Room::GRID_HEIGHT, room.height
  end
end
