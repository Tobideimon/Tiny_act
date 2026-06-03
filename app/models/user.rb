class User < ApplicationRecord
  AVATARS = %w[
    blueberry
    cloud
    frog
    clove
  ]

  validates :avatar, inclusion: { in: AVATARS }, allow_blank: true
  has_one :room, dependent: :destroy
  has_many :activity_sessions, dependent: :destroy
  has_many :user_interests, dependent: :destroy
  has_many :interests, through: :user_interests
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  after_create :create_default_room

  private

  def create_default_room
    create_room!(width: 8, height: 8)
  end
end
