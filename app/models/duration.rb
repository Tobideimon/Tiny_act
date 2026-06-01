class Duration < ApplicationRecord
  has_many :activities, dependent: :destroy

  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
