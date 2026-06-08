class AddFamilyTopicToCodeQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column :code_questions, :topic, :string
    add_column :code_questions, :family, :string
    add_index  :code_questions, :difficulty
    add_index  :code_questions, :family
  end
end
