class CreateMelodies < ActiveRecord::Migration[8.1]
  def change
    create_table :melodies do |t|
      t.string  :name,       null: false
      t.jsonb   :notes,      null: false, default: []
      t.string  :difficulty, null: false
      t.string  :category,   null: false
      t.string  :family
      t.string  :topic
      t.string  :source
      t.timestamps
    end
    add_index :melodies, :name, unique: true
    add_index :melodies, :difficulty
    add_index :melodies, :family
  end
end
