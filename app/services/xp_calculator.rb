class XpCalculator
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
