class CreateActivitySessions < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true
      t.date :date
      t.integer :rating
      t.boolean :finished, default: false, null: false

      t.timestamps
    end
  end
end
