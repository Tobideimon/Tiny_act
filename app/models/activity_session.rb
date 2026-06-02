class ActivitySession < ApplicationRecord
  LANGUAGES = %w[english spanish]

  belongs_to :user
  belongs_to :activity

  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :language, inclusion: { in: LANGUAGES }, allow_nil: true
end
