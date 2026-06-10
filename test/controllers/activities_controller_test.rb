require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    activity = create_activity!

    get activity_path(activity)

    assert_redirected_to new_user_session_path
  end

  test "show renders an activity for the current user's session" do
    user = create_user!
    activity = create_activity!(name: "Focused activity")
    activity_session = ActivitySession.create!(
      user: user,
      activity: activity,
      status: "selecting"
    )

    sign_in user

    get activity_path(activity, activity_session_id: activity_session.id)

    assert_response :success
    assert_includes response.body, "Focused activity"
    assert_equal "preview", activity_session.reload.status
  end

  test "show redirects when the session does not belong to current user" do
    user = create_user!
    activity = create_activity!
    other_session = ActivitySession.create!(
      user: create_user!,
      activity: activity,
      status: "selecting"
    )

    sign_in user

    get activity_path(activity, activity_session_id: other_session.id)

    assert_redirected_to root_path
  end
end
