class Room < ApplicationRecord
  GRID_WIDTH = 5
  GRID_HEIGHT = 5

  belongs_to :user
  has_many :room_furnitures, dependent: :destroy

  def ensure_default_size!
    return if width == GRID_WIDTH && height == GRID_HEIGHT

    update!(width: GRID_WIDTH, height: GRID_HEIGHT)
  end
end
