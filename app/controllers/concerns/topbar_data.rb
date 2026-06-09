module TopbarData
  extend ActiveSupport::Concern

  private

  def set_topbar_data
    @finished_sessions_count = current_user.activity_sessions.where(finished: true).count
    @home_xp = XpCalculator.total_for(current_user)
  end
end
