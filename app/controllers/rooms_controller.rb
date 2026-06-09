class RoomsController < ApplicationController
  include TopbarData

  before_action :authenticate_user!
  before_action :set_topbar_data, only: [:show]

  def index
    @rooms = Room
      .includes(:user, :room_likes, room_furnitures: :furniture)
      .left_joins(:room_likes)
      .group("rooms.id")
      .order("COUNT(room_likes.id) DESC")
  end
  def show
    @room = current_user.room || current_user.create_room!(width: Room::GRID_WIDTH, height: Room::GRID_HEIGHT)
    @room.ensure_default_size!

    @available_furnitures = Furniture
                            .joins(:interest)
                            .select do |furniture|
                              user_xp = XpCalculator.total_for_interest(
                                current_user,
                                furniture.interest
                              )

                              user_xp >= furniture.required_xp
                            end

    @room_data = {
      id: @room.id,
      width: @room.width,
      height: @room.height,
      furnitures: @room.room_furnitures.includes(:furniture).map do |item|
        {
          id: item.id,
          furniture_id: item.furniture_id,
          name: item.furniture.name,
          image_url: ActionController::Base.helpers.asset_path(item.furniture.image_url),
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
