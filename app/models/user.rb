class User < ApplicationRecord
  AVATARS = (1..24).map { |number| "avatar_#{number.to_s.rjust(2, '0')}" }

  validates :avatar, inclusion: { in: AVATARS }, allow_blank: true

  has_one :room, dependent: :destroy
  has_many :user_interest_progresses, dependent: :destroy
  has_many :activity_sessions, dependent: :destroy
  has_many :user_interests, dependent: :destroy
  has_many :interests, through: :user_interests
  has_many :room_likes, dependent: :destroy
  has_many :liked_rooms, through: :room_likes, source: :room

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :create_default_room

  private

  def create_default_room
    create_room!(width: Room::GRID_WIDTH, height: Room::GRID_HEIGHT)
  end
end
