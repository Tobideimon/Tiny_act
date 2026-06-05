class ActivitiesController < ApplicationController
  include TopbarData

  before_action :authenticate_user!
  before_action :set_topbar_data, only: [:show]

  def show
    @activity = Activity.find(params[:id])
    @activity_session = current_user.activity_sessions.find_by(id: params[:activity_session_id])

    unless @activity_session
      redirect_to root_path, alert: "Session introuvable."
      return
    end

    @activity_session.update!(activity: @activity)

    assign_activity_context
  end

  private

  def assign_activity_context
    activity_context = ActivityLoaders::Factory
                       .for(activity: @activity, activity_session: @activity_session)
                       .call

    activity_context.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end
end
