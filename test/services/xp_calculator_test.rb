require "test_helper"

class XpCalculatorTest < ActiveSupport::TestCase
  test "awards stores and reads xp from the calculator rules" do
    user = create_user!(email: "xp@example.com")
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
    activity_session = ActivitySession.create!(
      user: user,
      activity: activity,
      finished: true,
      status: "finished",
      date: Date.current
    )

    assert_equal 29, XpCalculator.award!(activity_session)

    activity_session.reload
    assert_equal 29, activity_session.xp_earned
    assert_equal 29, activity_session.awarded_xp
    assert_equal 29, XpCalculator.total_for(user)
    assert_equal 29, XpCalculator.total_for_interest(user, interest)
    assert_equal 29, UserInterestProgress.find_by!(user: user, interest: interest).xp

    assert_equal 29, XpCalculator.award!(activity_session)
    assert_equal 29, XpCalculator.total_for(user)
    assert_equal 29, XpCalculator.total_for_interest(user, interest)
  end

  test "does not award xp twice" do
    user = create_user!
    activity = create_activity!(duration_value: 5)
    activity_session = ActivitySession.create!(
      user: user,
      activity: activity,
      finished: true,
      status: "finished"
    )

    assert_equal 10, XpCalculator.award!(activity_session)
    awarded_at = activity_session.reload.xp_awarded_at

    travel 1.minute do
      assert_no_changes -> { XpCalculator.total_for(user) } do
        assert_equal 10, XpCalculator.award!(activity_session)
      end
    end

    assert_equal awarded_at.to_i, activity_session.reload.xp_awarded_at.to_i
  end

  test "syncs progress only for the session interest" do
    user = create_user!
    sport = Interest.create!(name: "Sport")
    drawing = Interest.create!(name: "Drawing")
    sport_activity = create_activity!(interest: sport, duration_value: 30)
    drawing_activity = create_activity!(interest: drawing, duration_value: 5)

    create_finished_session!(user: user, activity: sport_activity, xp_earned: 40)
    drawing_session = ActivitySession.create!(
      user: user,
      activity: drawing_activity,
      finished: true,
      status: "finished"
    )

    XpCalculator.award!(drawing_session)

    assert_equal 10, UserInterestProgress.find_by!(user: user, interest: drawing).xp
    assert_nil UserInterestProgress.find_by(user: user, interest: sport)
  end
end
