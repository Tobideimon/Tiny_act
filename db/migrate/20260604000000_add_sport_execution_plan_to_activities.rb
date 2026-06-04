class AddSportExecutionPlanToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :preparation_seconds, :integer, null: false, default: 30
    add_column :activities, :execution_plan, :jsonb, null: false, default: {}
  end
end
