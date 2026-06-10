require "test_helper"

class ActivitySessionsControllerTest < ActionDispatch::IntegrationTest
  test "index requires authentication" do
    get activity_sessions_path

    assert_redirected_to new_user_session_path
  end

  test "index lists only current user's finished sessions" do
    user = create_user!
    other_user = create_user!
    user_activity = create_activity!(name: "Visible session")
    other_activity = create_activity!(name: "Hidden session")

    create_finished_session!(user: user, activity: user_activity)
    create_finished_session!(user: other_user, activity: other_activity)
    ActivitySession.create!(
      user: user,
      activity: create_activity!(name: "Unfinished session"),
      finished: false,
      status: "paused"
    )

    sign_in user

    get activity_sessions_path

    assert_response :success
    assert_includes response.body, "Visible session"
    assert_no_match "Hidden session", response.body
    assert_no_match "Unfinished session", response.body
  end

  test "show does not expose another user's session" do
    user = create_user!
    other_session = ActivitySession.create!(
      user: create_user!,
      activity: create_activity!,
      status: "selecting"
    )

    sign_in user

    get activity_session_path(other_session)

    assert_response :not_found
  end

  test "update finishes a session and awards xp once" do
    user = create_user!
    activity = create_activity!(duration_value: 15, mood_name: "En forme")
    activity_session = ActivitySession.create!(
      user: user,
      activity: activity,
      date: Date.current,
      status: "in_progress"
    )

    sign_in user

    assert_difference -> { XpCalculator.total_for(user) }, 22 do
      patch activity_session_path(activity_session)
    end

    activity_session.reload
    assert activity_session.finished?
    assert_equal "finished", activity_session.status
    assert_equal 22, activity_session.xp_earned

    assert_no_changes -> { XpCalculator.total_for(user) } do
      patch activity_session_path(activity_session)
    end
  end

  test "new shows closest next furniture unlock across selected interests" do
    user = create_user!(email: "next-unlock@example.com")
    sport = Interest.create!(name: "Sport")
    drawing = Interest.create!(name: "Drawing")
    music = Interest.create!(name: "Music")
    Mood.create!(name: "En forme")
    mood = Mood.create!(name: "À plat")
    duration = Duration.create!(value: 15)
    location = Location.create!(name: "Maison")

    UserInterest.create!(user: user, interest: sport)
    UserInterest.create!(user: user, interest: drawing)

    sport_activity = Activity.create!(
      name: "Move",
      content: "Move a little",
      interest: sport,
      mood: mood,
      duration: duration,
      location: location
    )
    drawing_activity = Activity.create!(
      name: "Sketch",
      content: "Draw a little",
      interest: drawing,
      mood: mood,
      duration: duration,
      location: location
    )

    ActivitySession.create!(
      user: user,
      activity: sport_activity,
      date: Date.current,
      finished: true,
      xp_earned: 40,
      xp_awarded_at: Time.current
    )
    ActivitySession.create!(
      user: user,
      activity: drawing_activity,
      date: Date.current,
      finished: true,
      xp_earned: 10,
      xp_awarded_at: Time.current
    )

    Furniture.create!(
      name: "Tapis de sport",
      image_url: "furnitures/tapis.png",
      width: 1,
      height: 1,
      required_xp: 60,
      interest: sport
    )
    Furniture.create!(
      name: "Ballon déjà acquis",
      image_url: "furnitures/ballon.png",
      width: 1,
      height: 1,
      required_xp: 30,
      interest: sport
    )
    Furniture.create!(
      name: "Bureau dessin",
      image_url: "furnitures/bureau.png",
      width: 1,
      height: 1,
      required_xp: 100,
      interest: drawing
    )
    Furniture.create!(
      name: "Piano secret",
      image_url: "furnitures/piano.png",
      width: 1,
      height: 1,
      required_xp: 45,
      interest: music
    )

    sign_in user

    get new_activity_session_path

    assert_response :success
    assert_includes(
      response.body,
      "Plus que 20 XP en Sport pour débloquer Tapis de sport."
    )
    assert_no_match "Bureau dessin", response.body
    assert_no_match "Ballon déjà acquis", response.body
    assert_no_match "Piano secret", response.body
  end

  test "shows newly unlocked furniture once on the finished summary" do
    user = create_user!(email: "unlock@example.com")
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
