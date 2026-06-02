class CreateLanguageItems < ActiveRecord::Migration[8.1]
  def change
    create_table :language_items do |t|
      t.string :item_type
      t.text :prompt
      t.string :answer
      t.text :translation
      t.string :language

      t.timestamps
    end
  end
end
