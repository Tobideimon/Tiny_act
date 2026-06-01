class Activity < ApplicationRecord
  belongs_to :duration
  belongs_to :interest
  belongs_to :location
  belongs_to :mood

  has_many :activity_sessions, dependent: :destroy

  validates :name, presence: true
  validates :content, presence: true
end
