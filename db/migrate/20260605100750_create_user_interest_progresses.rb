class CreateUserInterestProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :user_interest_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :interest, null: false, foreign_key: true
      t.integer :xp

      t.timestamps
    end
  end
end
