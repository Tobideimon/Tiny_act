require "test_helper"

class RoomLikesControllerTest < ActionDispatch::IntegrationTest
  test "create requires authentication" do
    post room_like_path(create_user!.room)

    assert_redirected_to new_user_session_path
  end

  test "create likes a room only once for the current user" do
    user = create_user!
    room = create_user!.room

    sign_in user

    assert_difference -> { RoomLike.count }, 1 do
      post room_like_path(room)
    end

    assert_no_difference -> { RoomLike.count } do
      post room_like_path(room)
    end

    assert_redirected_to rooms_path
  end

  test "destroy removes only the current user's like" do
    user = create_user!
    other_user = create_user!
    room = create_user!.room
    user_like = RoomLike.create!(user: user, room: room)
    other_like = RoomLike.create!(user: other_user, room: room)

    sign_in user

    assert_difference -> { RoomLike.count }, -1 do
      delete room_like_path(room)
    end

    assert_not RoomLike.exists?(user_like.id)
    assert RoomLike.exists?(other_like.id)
    assert_redirected_to rooms_path
  end
end
