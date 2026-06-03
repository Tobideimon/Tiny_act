class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    @room = current_user.room || current_user.create_room!(width: 8, height: 8)

    @room_data = {
      id: @room.id,
      width: @room.width,
      height: @room.height,
      furnitures: @room.room_furnitures.includes(:furniture).map do |item|
        {
          id: item.id,
          furniture_id: item.furniture_id,
          name: item.furniture.name,
          image_url: item.furniture.image_url,
          width: item.furniture.width,
          height: item.furniture.height,
          x: item.x,
          y: item.y,
          z: item.z,
          rotation: item.rotation
        }
      end
    }
  end
end
