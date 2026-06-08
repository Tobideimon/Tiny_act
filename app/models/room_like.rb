class RoomLike < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :user_id, uniqueness: { scope: :room_id }
end
