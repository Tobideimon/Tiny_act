class User < ApplicationRecord
  AVATARS = %w[
    blueberry
    cloud
    frog
  ]

  validates :avatar, inclusion: { in: AVATARS }, allow_blank: true

  has_many :activity_sessions, dependent: :destroy
  has_many :user_interests, dependent: :destroy
  has_many :interests, through: :user_interests
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
