class RoomLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    room = Room.find(params[:room_id])

    RoomLike.find_or_create_by!(
      user: current_user,
      room: room
    )

    redirect_to rooms_path
  end

  def destroy
    room = Room.find(params[:room_id])

    current_user.room_likes.find_by(room: room)&.destroy

    redirect_to rooms_path
  end
end
