class AddSportDetailsToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :description, :text
    add_column :activities, :steps, :text
  end
end
