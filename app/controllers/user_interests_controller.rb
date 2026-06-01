class UserInterestsController < ApplicationController
  before_action :authenticate_user!

  def show
    @interests = Interest.all
    @selected_interest_ids = current_user.interest_ids
  end

  def update
    interest_ids = params[:interest_ids] || []

    current_user.interest_ids = interest_ids

    redirect_to user_path(current_user), notice: "Tes centres d'intérêt ont été mis à jour."
  end
end
