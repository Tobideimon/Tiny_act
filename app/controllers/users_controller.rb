class UsersController < ApplicationController
  before_action :authenticate_user!
  def show
    @user = current_user
    @room = @user.room || @user.create_room!(width: Room::GRID_WIDTH, height: Room::GRID_HEIGHT)
    @room.ensure_default_size!
    @furniture_unlock_progress = Interest.all.map do |interest|
      current_xp = XpCalculator.total_for_interest(@user, interest)

      next_furniture = Furniture
        .where(interest: interest)
        .where("required_xp > ?", current_xp)
        .order(:required_xp)
        .first

      next unless next_furniture

      {
        interest: interest,
        current_xp: current_xp,
        next_furniture: next_furniture,
        required_xp: next_furniture.required_xp,
        percentage: [
          (current_xp.to_f / next_furniture.required_xp * 100).round,
          100
        ].min
      }
    end.compact

    @next_unlocks = @furniture_unlock_progress.sort_by do |progress|
      progress[:required_xp] - progress[:current_xp]
    end

    @main_next_unlock = @next_unlocks.first
    @secondary_next_unlocks = @next_unlocks.drop(1).first(2)
    
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

  def edit
    @user = current_user
    @avatars = User::AVATARS
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to user_path, notice: "Avatar mis à jour !"
    else
      @avatars = User::AVATARS
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:avatar)
  end
end
