class AddProgressToActivitySessions < ActiveRecord::Migration[8.1]
  def change
    add_column :activity_sessions, :status, :string, null: false, default: "selecting"
    add_column :activity_sessions, :elapsed_seconds, :integer, null: false, default: 0
    add_column :activity_sessions, :timer_started_at, :datetime

    add_index :activity_sessions, :status
  end
end
