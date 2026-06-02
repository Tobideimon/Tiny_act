class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
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
