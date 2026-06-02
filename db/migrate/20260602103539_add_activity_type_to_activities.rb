class AddActivityTypeToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :activity_type, :string, default: "standard", null: false
  end
end
