class CreateFurnitures < ActiveRecord::Migration[8.1]
  def change
    create_table :furnitures do |t|
      t.string :name
      t.string :image_url
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
