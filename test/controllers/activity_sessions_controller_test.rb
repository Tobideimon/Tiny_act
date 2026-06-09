require "test_helper"

class ActivitySessionsControllerTest < ActionDispatch::IntegrationTest
  test "shows newly unlocked furniture once on the finished summary" do
    user = User.create!(email: "unlock@example.com", password: "password")
    interest = Interest.create!(name: "Sport")
    mood = Mood.create!(name: "À plat")
    duration = Duration.create!(value: 15)
    location = Location.create!(name: "Maison")
    activity = Activity.create!(
      name: "Move",
      content: "Move a little",
      interest: interest,
      mood: mood,
      duration: duration,
      location: location
    )
    furniture = Furniture.create!(
      name: "Canapé solaire",
      image_url: "furnitures/Canap.png",
      width: 1,
      height: 1,
      required_xp: 20,
      interest: interest
    )
    activity_session = ActivitySession.create!(
      user: user,
      activity: activity,
      date: Date.current
    )

    sign_in user

    patch activity_session_path(activity_session)
    follow_redirect!

    assert_response :success
    assert_includes response.body, "Nouveau meuble débloqué"
    assert_includes response.body, furniture.name

    activity_session.reload
    assert_equal [furniture.id], activity_session.newly_unlocked_furniture_ids
    assert activity_session.furniture_unlocks_seen_at.present?

    get activity_session_path(activity_session)

    assert_response :success
    assert_includes response.body, "Continue à progresser"
    assert_no_match furniture.name, response.body
  end
end
