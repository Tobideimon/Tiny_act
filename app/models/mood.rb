class Mood < ApplicationRecord
  has_many :activities, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
