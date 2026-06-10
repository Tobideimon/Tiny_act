require "test_helper"

class UserInterestProgressTest < ActiveSupport::TestCase
  test "stores xp for a user and interest" do
    user = create_user!
    interest = Interest.create!(name: "Sport")

    progress = UserInterestProgress.create!(
      user: user,
      interest: interest,
      xp: 42
    )

    assert_equal user, progress.user
    assert_equal interest, progress.interest
    assert_equal 42, progress.xp
  end
end
