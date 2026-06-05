class AddRequiredXpToFurnitures < ActiveRecord::Migration[8.1]
  def change
    add_column :furnitures, :required_xp, :integer
  end
end
