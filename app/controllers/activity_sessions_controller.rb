class ActivitySessionsController < ApplicationController
  before_action :set_activity_session, only: %i[show update done rate summary]

  def new
    @moods = Mood.all
  end

  def location
    @mood = Mood.find(params[:mood_id])
    @locations = Location.all
  end

  def duration
    @mood = Mood.find(params[:mood_id])
    @location = Location.find(params[:location_id])
    @durations = Duration.order(:value)
  end

  def offer
    @mood = Mood.find(params[:mood_id])
    @location = Location.find(params[:location_id])
    @duration = Duration.find(params[:duration_id])

    @activities = find_matching_activities

    return unless @activities.size < 3

    flash.now[:alert] = "Il n’y a pas encore assez d’activités correspondant exactement à ce choix."
  end

  def choose
    activity = Activity.find(params[:activity_id])

    @activity_session = ActivitySession.create!(
      user: current_user,
      activity: activity,
      date: Date.current
    )

    redirect_to activity_session_path(@activity_session)
  end

  def show
  end

  def done
    @activity_session.update!(finished: true)
    redirect_to summary_activity_session_path(@activity_session)
  end

  def rate
    if @activity_session.update(rating_params)
      redirect_to summary_activity_session_path(@activity_session)
    else
      render :summary, status: :unprocessable_entity
    end
  end

  def summary
  end

  def update
    if @activity_session.update(activity_session_params)
      redirect_to activity_session_path(@activity_session)
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_activity_session
    @activity_session = current_user.activity_sessions.find(params[:id])
  end

  def find_matching_activities
    exact_scope = Activity
                  .includes(:interest, :mood, :location, :duration)
                  .where(
                    active: true,
                    mood: @mood,
                    location: @location,
                    duration: @duration
                  )

    selected_activities = []

    if current_user.interests.any?
      preferred_scope = exact_scope.where(interest_id: current_user.interest_ids)
      selected_activities += pick_activities_with_different_interests(preferred_scope, limit: 3)
    end

    if selected_activities.size < 3
      remaining_scope = exact_scope.where.not(id: selected_activities.map(&:id))
      selected_activities += pick_activities_with_different_interests(
        remaining_scope,
        limit: 3 - selected_activities.size,
        already_used_interest_ids: selected_activities.map(&:interest_id)
      )
    end

    if selected_activities.size < 3
      remaining_scope = exact_scope.where.not(id: selected_activities.map(&:id))
      selected_activities += remaining_scope.order(Arel.sql("RANDOM()")).limit(3 - selected_activities.size).to_a
    end

    selected_activities.first(3)
  end

  def pick_activities_with_different_interests(scope, limit:, already_used_interest_ids: [])
    selected = []
    used_interest_ids = already_used_interest_ids.compact.dup

    scope.order(Arel.sql("RANDOM()")).each do |activity|
      next if used_interest_ids.include?(activity.interest_id)

      selected << activity
      used_interest_ids << activity.interest_id

      break if selected.size == limit
    end

    selected
  end

  def activity_session_params
    params.require(:activity_session).permit(:finished, :rating)
  end

  def rating_params
    params.require(:activity_session).permit(:rating)
  end
end
