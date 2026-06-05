class CodeQuestion < ApplicationRecord
  validates :question, presence: true, uniqueness: true
  validates :correct_answer, presence: true
  validates :wrong_answer_1, presence: true
  validates :wrong_answer_2, presence: true
  validates :wrong_answer_3, presence: true
  validates :category, presence: true
  validates :difficulty, presence: true

  def answers
    [correct_answer, wrong_answer_1, wrong_answer_2, wrong_answer_3].shuffle
  end
end
