require "test_helper"

class XpCalculatorTest < ActiveSupport::TestCase
  test "awards stores and reads xp from the calculator rules" do
    user = User.create!(email: "xp@example.com", password: "password")
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
end
