class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :name
      t.text :content
      t.boolean :active, default: true, null: false
      t.references :interest, null: false, foreign_key: true
      t.references :mood, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :duration, null: false, foreign_key: true

      t.timestamps
    end
  end
end
