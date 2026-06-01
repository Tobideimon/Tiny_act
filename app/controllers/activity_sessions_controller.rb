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

    @activities = find_three_activities
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

  def find_three_activities
    selected_activities = []

    selected_activities += exact_matching_activities.to_a

    selected_activities += interest_matching_activities.to_a if selected_activities.size < 3

    selected_activities += mood_matching_activities.to_a if selected_activities.size < 3

    selected_activities += fallback_activities.to_a if selected_activities.size < 3

    selected_activities.uniq(&:id).first(3)
  end

  def exact_matching_activities
    activities = Activity.where(
      active: true,
      mood: @mood,
      location: @location,
      duration: @duration
    )

    activities = activities.where(interest_id: current_user.interest_ids) if current_user.interests.any?

    activities.order(Arel.sql("RANDOM()"))
  end

  def interest_matching_activities
    return Activity.none unless current_user.interests.any?

    Activity.where(active: true, interest_id: current_user.interest_ids)
            .order(Arel.sql("RANDOM()"))
  end

  def mood_matching_activities
    Activity.where(active: true, mood: @mood)
            .order(Arel.sql("RANDOM()"))
  end

  def fallback_activities
    Activity.where(active: true)
            .order(Arel.sql("RANDOM()"))
  end

  def activity_session_params
    params.require(:activity_session).permit(:finished, :rating)
  end

  def rating_params
    params.require(:activity_session).permit(:rating)
  end
end
