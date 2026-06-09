class AddFurnitureUnlockNotificationsToActivitySessions < ActiveRecord::Migration[8.1]
  def change
    add_column :activity_sessions, :newly_unlocked_furniture_ids, :jsonb, null: false, default: []
    add_column :activity_sessions, :furniture_unlocks_seen_at, :datetime
  end
end
