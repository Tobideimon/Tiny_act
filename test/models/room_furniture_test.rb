require "test_helper"

class RoomFurnitureTest < ActiveSupport::TestCase
  test "belongs to a room and a furniture item" do
    room_furniture = RoomFurniture.new(x: 0, y: 0, z: 0, rotation: 0)

    assert_not room_furniture.valid?
    assert_includes room_furniture.errors[:room], "must exist"
    assert_includes room_furniture.errors[:furniture], "must exist"
  end
end
