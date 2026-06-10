require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  test "index requires authentication" do
    get rooms_path

    assert_redirected_to new_user_session_path
  end

  test "index shows rooms ordered by like count" do
    user = create_user!
    popular_owner = create_user!(first_name: "Popular")
    quiet_owner = create_user!(first_name: "Quiet")
    RoomLike.create!(user: create_user!, room: popular_owner.room)
    RoomLike.create!(user: create_user!, room: popular_owner.room)
    RoomLike.create!(user: create_user!, room: quiet_owner.room)

    sign_in user

    get rooms_path

    assert_response :success
    assert_match(/Room de Popular.*Room de Quiet/m, response.body)
  end

  test "show exposes only furniture unlocked by current user's interest xp" do
    user = create_user!
    sport = Interest.create!(name: "Sport")
    music = Interest.create!(name: "Music")
    sport_activity = create_activity!(interest: sport)
    create_finished_session!(user: user, activity: sport_activity, xp_earned: 25)

    Furniture.create!(
      name: "Unlocked desk",
      image_url: "furnitures/Bureau.png",
      width: 1,
      height: 1,
      required_xp: 20,
      interest: sport
    )
    Furniture.create!(
      name: "Locked desk",
      image_url: "furnitures/Bed.png",
      width: 1,
      height: 1,
      required_xp: 30,
      interest: sport
    )
    Furniture.create!(
      name: "Other interest desk",
      image_url: "furnitures/chair.png",
      width: 1,
      height: 1,
      required_xp: 1,
      interest: music
    )

    sign_in user

    get room_path(user.room)

    assert_response :success
    assert_includes response.body, "Unlocked desk"
    assert_no_match "Locked desk", response.body
    assert_no_match "Other interest desk", response.body
  end
end
