class AddInterestToFurnitures < ActiveRecord::Migration[8.1]
  def change
    add_reference :furnitures, :interest, null: false, foreign_key: true
  end
end
