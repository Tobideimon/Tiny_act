class CreateUserInterests < ActiveRecord::Migration[8.1]
  def change
    create_table :user_interests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :interest, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_interests, [:user_id, :interest_id], unique: true
  end
end
