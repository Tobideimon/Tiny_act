class CreateDurations < ActiveRecord::Migration[8.1]
  def change
    create_table :durations do |t|
      t.integer :value

      t.timestamps
    end
  end
end
