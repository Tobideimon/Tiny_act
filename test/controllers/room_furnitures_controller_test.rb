require "test_helper"

class RoomFurnituresControllerTest < ActionDispatch::IntegrationTest
  test "create requires authentication" do
    furniture = create_furniture

    post room_furnitures_path, params: {
      room_furniture: {
        furniture_id: furniture.id,
        z: 0,
        rotation: 0
      }
    }

    assert_redirected_to new_user_session_path
  end

  test "create places furniture in the current user's room" do
    user = create_user!
    furniture = create_furniture

    sign_in user

    assert_difference -> { user.room.room_furnitures.count }, 1 do
      post room_furnitures_path(format: :json), params: {
        room_furniture: {
          furniture_id: furniture.id,
          z: 2,
          rotation: 90
        }
      }
    end

    assert_response :success
    item = user.room.room_furnitures.last
    assert_equal furniture, item.furniture
    assert_equal 0, item.x
    assert_equal 0, item.y
    assert_equal 2, item.z
    assert_equal 90, item.rotation
  end

  test "update moves furniture only inside the current user's room" do
    user = create_user!
    item = user.room.room_furnitures.create!(
      furniture: create_furniture,
      x: 0,
      y: 0,
      z: 0,
      rotation: 0
    )

    sign_in user

    patch room_furniture_path(item), params: {
      room_furniture: {
        x: 2,
        y: 1,
        z: 3,
        rotation: 180
      }
    }

    assert_response :success
    item.reload
    assert_equal 2, item.x
    assert_equal 1, item.y
    assert_equal 3, item.z
    assert_equal 180, item.rotation
  end

  test "update rejects out of bounds placement" do
    user = create_user!
    item = user.room.room_furnitures.create!(
      furniture: create_furniture(width: 2, height: 2),
      x: 0,
      y: 0,
      z: 0,
      rotation: 0
    )

    sign_in user

    patch room_furniture_path(item), params: {
      room_furniture: {
        x: Room::GRID_WIDTH,
        y: 0,
        z: 0,
        rotation: 0
      }
    }

    assert_response :unprocessable_entity
    assert_equal 0, item.reload.x
  end

  test "cannot update furniture from another user's room" do
    user = create_user!
    other_item = create_user!.room.room_furnitures.create!(
      furniture: create_furniture,
      x: 0,
      y: 0,
      z: 0,
      rotation: 0
    )

    sign_in user

    patch room_furniture_path(other_item), params: {
      room_furniture: {
        x: 1,
        y: 1,
        z: 0,
        rotation: 0
      }
    }

    assert_response :not_found
    assert_equal 0, other_item.reload.x
  end

  test "destroy removes furniture only from the current user's room" do
    user = create_user!
    item = user.room.room_furnitures.create!(
      furniture: create_furniture,
      x: 0,
      y: 0,
      z: 0,
      rotation: 0
    )

    sign_in user

    assert_difference -> { user.room.room_furnitures.count }, -1 do
      delete room_furniture_path(item)
    end

    assert_response :success
  end

  test "cannot destroy furniture from another user's room" do
    user = create_user!
    other_item = create_user!.room.room_furnitures.create!(
      furniture: create_furniture,
      x: 0,
      y: 0,
      z: 0,
      rotation: 0
    )

    sign_in user

    delete room_furniture_path(other_item)

    assert_response :not_found
    assert RoomFurniture.exists?(other_item.id)
  end

  private

  def create_furniture(width: 1, height: 1)
    Furniture.create!(
      name: "Test furniture #{SecureRandom.hex(4)}",
      image_url: "furnitures/Bureau.png",
      width: width,
      height: height,
      required_xp: 0,
      interest: Interest.create!(name: "Furniture interest #{SecureRandom.hex(4)}")
    )
  end
end
