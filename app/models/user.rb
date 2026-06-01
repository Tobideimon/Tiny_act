class User < ApplicationRecord
  has_many :activity_sessions, dependent: :destroy
  has_many :user_interests, dependent: :destroy
  has_many :interests, through: :user_interests

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
