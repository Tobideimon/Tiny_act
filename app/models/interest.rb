class Interest < ApplicationRecord
  has_many :activities, dependent: :destroy
  has_many :user_interests, dependent: :destroy
  has_many :users, through: :user_interests

  validates :name, presence: true, uniqueness: true
end
