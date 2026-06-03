class RoomFurnituresController < ApplicationController
  before_action :authenticate_user!

  def update
    item = current_user.room.room_furnitures.find(params[:id])

    new_x = room_furniture_params[:x].to_i
    new_y = room_furniture_params[:y].to_i

    if can_place?(item, new_x, new_y)
      item.update!(room_furniture_params)
      render json: item
    else
      render json: { error: "Position invalide" }, status: :unprocessable_entity
    end
  end

  def create
    furniture = Furniture.find(params[:room_furniture][:furniture_id])
    position = first_free_position(current_user.room, furniture)

    unless position
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.json { render json: { error: "Aucune place disponible" }, status: :unprocessable_entity }
        format.html { redirect_to user_path, alert: "Aucune place disponible" }
      end

      return
    end

    item = current_user.room.room_furnitures.create!(
      furniture: furniture,
      x: position[:x],
      y: position[:y],
      z: params[:room_furniture][:z],
      rotation: params[:room_furniture][:rotation]
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "profile-room",
          partial: "users/room",
          locals: {
            room_data: room_data(current_user.room),
            editable: true
          }
        )
      end

      format.json { render json: room_furniture_json(item) }
      format.html { redirect_to user_path }
    end
  end

  def destroy
    item = current_user
      .room
      .room_furnitures
      .find(params[:id])

    item.destroy!

    head :ok
  end

  private

  def room_furniture_params
    params.require(:room_furniture).permit(:x, :y, :z, :rotation)
  end

  def can_place?(item, new_x, new_y)
    return false if new_x < 0 || new_y < 0
    return false if new_x + item.furniture.width > item.room.width
    return false if new_y + item.furniture.height > item.room.height

    item.room.room_furnitures.where.not(id: item.id).includes(:furniture).none? do |other|
      new_x < other.x + other.furniture.width &&
        new_x + item.furniture.width > other.x &&
        new_y < other.y + other.furniture.height &&
        new_y + item.furniture.height > other.y
    end
  end

  def room_data(room)
    {
      id: room.id,
      width: room.width,
      height: room.height,
      furnitures: room.room_furnitures.includes(:furniture).map do |item|
        room_furniture_json(item)
      end
    }
  end

  def room_furniture_json(item)
    {
      id: item.id,
      furniture_id: item.furniture_id,
      name: item.furniture.name,
      image_url: helpers.asset_path(item.furniture.image_url),
      width: item.furniture.width,
      height: item.furniture.height,
      x: item.x,
      y: item.y,
      z: item.z,
      rotation: item.rotation
    }
  end

  def first_free_position(room, furniture)
    (0..(room.height - furniture.height)).each do |y|
      (0..(room.width - furniture.width)).each do |x|
        return { x: x, y: y } if free_position?(room, furniture, x, y)
      end
    end

    nil
  end

  def free_position?(room, furniture, x, y)
    room.room_furnitures.includes(:furniture).none? do |item|
      x < item.x + item.furniture.width &&
        x + furniture.width > item.x &&
        y < item.y + item.furniture.height &&
        y + furniture.height > item.y
    end
  end
end
