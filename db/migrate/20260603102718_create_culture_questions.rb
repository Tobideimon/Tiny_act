class CreateCultureQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :culture_questions do |t|
      t.text :question
      t.string :correct_answer
      t.string :wrong_answer_1
      t.string :wrong_answer_2
      t.string :wrong_answer_3
      t.string :category
      t.string :difficulty
      t.string :source

      t.timestamps
    end
  end
end
