class Activity < ApplicationRecord
  ACTIVITY_TYPES = %w[standard word_learning sentence_completion llm_chat]
  LANGUAGE_ACTIVITY_TYPES = %w[word_learning sentence_completion llm_chat]

  belongs_to :duration
  belongs_to :interest
  belongs_to :location
  belongs_to :mood

  has_many :activity_sessions, dependent: :destroy

  validates :name, presence: true
  validates :content, presence: true
  validates :activity_type, presence: true, inclusion: { in: ACTIVITY_TYPES }

  def language_activity?
    LANGUAGE_ACTIVITY_TYPES.include?(activity_type)
  end
end
