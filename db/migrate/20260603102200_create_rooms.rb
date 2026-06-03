class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
