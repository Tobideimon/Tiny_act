class Furniture < ApplicationRecord
  has_many :room_furnitures
  belongs_to :interest
end
