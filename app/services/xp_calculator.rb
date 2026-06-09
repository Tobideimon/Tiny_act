class XpCalculator
  def self.reward_for(activity_session)
    new(activity_session).call
  end

  def self.awarded_xp_for(activity_session)
    return 0 if activity_session.xp_awarded_at.blank?

    activity_session.xp_earned.to_i
  end

  def self.award!(activity_session)
    return awarded_xp_for(activity_session) if activity_session.xp_awarded_at.present?

    ActivitySession.transaction do
      activity_session.lock!

      next if activity_session.xp_awarded_at.present?

      xp_earned = reward_for(activity_session)
      activity_session.update!(
        xp_earned: xp_earned,
        xp_awarded_at: Time.current
      )

      sync_interest_progress!(
        activity_session.user,
        activity_session.activity.interest
      )
    end

    awarded_xp_for(activity_session)
  end

  def self.total_for(user)
    awarded_sessions_for(user).sum(:xp_earned)
  end

  def self.total_for_interest(user, interest)
    awarded_sessions_for(user)
      .joins(:activity)
      .where(activities: { interest_id: interest.id })
      .sum(:xp_earned)
  end

  def self.sync_interest_progress!(user, interest)
    progress = UserInterestProgress.find_or_initialize_by(
      user: user,
      interest: interest
    )

    progress.xp = total_for_interest(user, interest)
    progress.save!
  end

  def self.awarded_sessions_for(user)
    user.activity_sessions.where.not(xp_awarded_at: nil)
  end

  def initialize(activity_session)
    @activity_session = activity_session
    @activity = activity_session.activity
  end

  def call
    (base_xp * mood_multiplier).round
  end

  private

  attr_reader :activity_session, :activity

  def base_xp
    case activity.duration.value.to_i
    when 5
      10
    when 15
      22
    when 30
      40
    else
      10
    end
  end

  def mood_multiplier
    case activity.mood.name
    when "À plat"
      1.3
    when "Bof", "Mitigé"
      1.15
    when "En forme"
      1.0
    else
      1.0
    end
  end
end
