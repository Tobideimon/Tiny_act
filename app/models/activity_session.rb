class ActivitySession < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
end
