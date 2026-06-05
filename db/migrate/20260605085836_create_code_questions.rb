class CreateCodeQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :code_questions do |t|
      t.string :question, null: false
      t.string :correct_answer, null: false
      t.string :wrong_answer_1, null: false
      t.string :wrong_answer_2, null: false
      t.string :wrong_answer_3, null: false
      t.string :category, null: false
      t.string :difficulty, null: false
      t.string :source
      t.timestamps
    end
    add_index :code_questions, :question, unique: true
  end
end
