class ActivitySessionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @moods = Mood.all
  end

  def location
    if params[:mood_id].blank?
      redirect_to new_activity_session_path, alert: "Choisis d'abord ton mood."
      return
    end

    @mood_id = params[:mood_id]
    @locations = Location.where.not(name: "N'importe où")
  end

  def duration
    if params[:mood_id].blank? || params[:location_id].blank?
      redirect_to new_activity_session_path, alert: "Recommence tes choix."
      return
    end

    @mood_id = params[:mood_id]
    @location_id = params[:location_id]
    @durations = Duration.order(:value)
  end

  def create
    activity = matching_activities.order(Arel.sql("RANDOM()")).first

    if activity
      @activity_session = current_user.activity_sessions.create!(
        activity: activity,
        date: Date.current
      )

      redirect_to activity_session_path(@activity_session)
    else
      redirect_to new_activity_session_path, alert: "Aucune activité trouvée."
    end
  end

  def show
    @activity_session = current_user.activity_sessions.find(params[:id])

    return if @activity_session.finished?

    reference_activity = @activity_session.activity

    matching_activities = Activity.where(
      active: true,
      mood: reference_activity.mood,
      duration: reference_activity.duration,
      interest_id: current_user.interests.ids,
      location_id: allowed_location_ids(reference_activity.location_id)
    )

    @activities = matching_activities
                  .includes(:interest)
                  .group_by(&:interest_id)
                  .values
                  .map(&:sample)
                  .sample(3)

    assign_language_if_needed
    @language_label = readable_language(@activity_session.language)
  end

  def update
    @activity_session = current_user.activity_sessions.find(params[:id])

    @activity_session.update!(finished: true)

    redirect_to activity_session_path(@activity_session)
  end

  private

  def matching_activities
    Activity.where(
      active: true,
      mood_id: params[:mood_id],
      duration_id: params[:duration_id],
      interest_id: current_user.interest_ids,
      location_id: allowed_location_ids(params[:location_id])
    )
  end

  def allowed_location_ids(selected_location_id)
    ids = [selected_location_id]

    anywhere = Location.find_by(name: "N'importe où")
    ids << anywhere.id if anywhere.present?

    ids
  end

  def load_language_items(activity)
    case activity.activity_type
    when "word_learning"
      load_random_language_items("word")
    when "sentence_completion"
      load_random_language_items("sentence")
    end
  end

  def load_random_language_items(item_type)
    language = LanguageItem
               .where(item_type: item_type)
               .distinct
               .pluck(:language)
               .sample

    return if language.blank?

    @language = language

    @language_items = LanguageItem
                      .where(item_type: item_type, language: language)
                      .order(Arel.sql("RANDOM()"))
                      .limit(5)
  end

  def assign_language_if_needed
    return unless @activities.any?(&:language_activity?)
    return if @activity_session.language.present?

    language = LanguageItem.distinct.pluck(:language).sample
    @activity_session.update!(language: language) if language.present?
  end

  def readable_language(language)
    {
      "english" => "anglais",
      "spanish" => "espagnol"
    }[language]
  end
end
