require "test_helper"

class ActivitySessionTest < ActiveSupport::TestCase
  test "tracks status helpers and remaining time" do
    user = create_user!
    activity = create_activity!(duration_value: 15)
    session = ActivitySession.create!(
      user: user,
      activity: activity,
      status: "in_progress",
      elapsed_seconds: 120
    )

    assert session.in_progress?
    assert_not session.paused?
    assert_not session.finished_status?
    assert_equal 900, session.duration_seconds
    assert_equal 780, session.remaining_seconds

    session.update!(status: "paused")

    assert session.paused?
  end

  test "does not expose awarded xp before xp is awarded" do
    session = ActivitySession.create!(
      user: create_user!,
      activity: create_activity!,
      status: "finished",
      finished: true,
      xp_earned: 22
    )

    assert_equal 0, session.awarded_xp
  end
end
