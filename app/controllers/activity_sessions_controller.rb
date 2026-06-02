class ActivitySessionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @moods = Mood.all
  end

  def location
    redirect_to new_activity_session_path, alert: "Choisis d'abord ton mood." if params[:mood_id].blank?

    @mood_id = params[:mood_id]
    @locations = Location.all
  end

  def duration
    if params[:mood_id].blank? || params[:location_id].blank?
      redirect_to new_activity_session_path, alert: "Recommence tes choix."
    end

    @mood_id = params[:mood_id]
    @location_id = params[:location_id]
    @durations = Duration.all
  end

  def create
    activity = Activity.where(
      mood_id: params[:mood_id],
      location_id: params[:location_id],
      duration_id: params[:duration_id],
      interest_id: current_user.interests.ids
    ).order("RANDOM()").first

    if activity
      @activity_session = current_user.activity_sessions.create(activity: activity)
      redirect_to activity_session_path(@activity_session)
    else
      redirect_to new_activity_session_path, alert: "Aucune activité trouvée."
    end
  end

  def show
    @activity_session = current_user.activity_sessions.find(params[:id])
    reference_activity = @activity_session.activity

    @activities = Activity.where(
      mood: reference_activity.mood,
      location: reference_activity.location,
      duration: reference_activity.duration,
      interest_id: current_user.interests.ids
    ).order("RANDOM()").limit(3)
  end
end
