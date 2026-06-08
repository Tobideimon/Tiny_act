class AddXpTrackingToActivitySessions < ActiveRecord::Migration[8.1]
  def change
    add_column :activity_sessions, :xp_earned, :integer, null: false, default: 0
    add_column :activity_sessions, :xp_awarded_at, :datetime
  end
end
