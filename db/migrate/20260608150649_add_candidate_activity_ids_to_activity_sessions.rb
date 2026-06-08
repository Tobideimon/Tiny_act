class AddCandidateActivityIdsToActivitySessions < ActiveRecord::Migration[8.1]
  def change
    add_column :activity_sessions, :candidate_activity_ids, :jsonb, default: [], null: false
  end
end
