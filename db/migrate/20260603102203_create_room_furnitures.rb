class CreateRoomFurnitures < ActiveRecord::Migration[8.1]
  def change
    create_table :room_furnitures do |t|
      t.references :room, null: false, foreign_key: true
      t.references :furniture, null: false, foreign_key: true
      t.integer :x
      t.integer :y
      t.integer :z
      t.integer :rotation

      t.timestamps
    end
  end
end
