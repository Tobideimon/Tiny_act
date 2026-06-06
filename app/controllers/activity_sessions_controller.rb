class ActivitySessionsController < ApplicationController
  include TopbarData

  before_action :authenticate_user!
  before_action :set_topbar_data, only: %i[new location duration show]

  def new
    @moods = Mood.all

    prepare_room_progress

    @home_notifications = build_home_notifications
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
        date: Date.current,
        status: "selecting",
        elapsed_seconds: 0
      )

      redirect_to activity_session_path(@activity_session)
    else
      redirect_to new_activity_session_path, alert: "Aucune activité trouvée."
    end
  end

  def show
    @activity_session = current_user.activity_sessions.find(params[:id])

    if @activity_session.finished?
      prepare_finished_summary
      return
    end

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

    if params[:activity_session].present?
      @activity_session.update!(activity_session_params)

      redirect_back fallback_location: activity_path(
        @activity_session.activity,
        activity_session_id: @activity_session.id
      )
    else
      was_already_finished = @activity_session.finished?

      @activity_session.update!(
        finished: true,
        status: "finished"
      )

      add_interest_xp_for(@activity_session) unless was_already_finished

      redirect_to activity_session_path(@activity_session)
    end
  end

  def progress
    @activity_session = current_user.activity_sessions.find(params[:id])

    return head :not_found if @activity_session.finished?

    elapsed_seconds = params[:elapsed_seconds].to_i
    elapsed_seconds = 0 if elapsed_seconds.negative?

    @activity_session.update!(
      elapsed_seconds: elapsed_seconds,
      status: "in_progress"
    )

    head :ok
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

  def activity_session_params
    params.require(:activity_session).permit(:culture_category)
  end

  def add_interest_xp_for(activity_session)
    interest = activity_session.activity.interest

    progress = UserInterestProgress.find_or_create_by!(
      user: current_user,
      interest: interest
    ) do |p|
      p.xp = 0
    end

    progress.increment!(:xp, 15)
  end

  def prepare_finished_summary
    @activity = @activity_session.activity
    @summary_interest_name = @activity&.interest&.name.presence || "Activité"
    @summary_duration_minutes = @activity&.duration&.value.to_i
    @summary_duration_label = @summary_duration_minutes.positive? ? "#{@summary_duration_minutes} min" : "Durée non renseignée"
    @summary_saved_scroll_minutes = @summary_duration_minutes.positive? ? @summary_duration_minutes : 15
    @summary_xp_gained = 15
  end

  # =========================
  # HOME NOTIFICATIONS
  # =========================

  def build_home_notifications
    notifications = [
      pending_activity_notification,
      room_progress_notification,
      daily_streak_notification
    ].compact

    add_notification_counters(notifications)
  end

  def add_notification_counters(notifications)
    total = notifications.size

    notifications.each_with_index.map do |notification, index|
      notification.merge(counter: "#{index + 1}/#{total}")
    end
  end

  def pending_activity_notification
    pending_activity_session = latest_pending_activity_session

    return if pending_activity_session.blank?

    activity = pending_activity_session.activity

    {
      kind: :pending,
      priority: 1,
      label: "REPRENDRE",
      title: activity.name.presence || "Activité en cours",
      subtitle: pending_activity_subtitle(pending_activity_session),
      icon_type: :play,
      url: activity_path(
        activity,
        activity_session_id: pending_activity_session.id
      ),
      tab_class: "tab-purple",
      decoration_class: nil
    }
  end

  def room_progress_notification
    prepare_room_progress unless defined?(@room_xp_before_reward)

    {
      kind: :room,
      priority: 2,
      label: "PROGRESSION",
      title: "Ta room progresse",
      subtitle: "Encore #{@room_xp_before_reward} XP avant un meuble",
      icon_type: :room,
      url: room_path,
      tab_class: "tab-gold",
      decoration_class: nil
    }
  end

  def daily_streak_notification
    today_count = finished_sessions_today_count

    return if today_count.zero?

    {
      kind: :streak,
      priority: 3,
      label: "SÉRIE",
      title: current_streak_title,
      subtitle: "#{today_count}/#{daily_bonus_goal} actions faites aujourd’hui",
      icon_type: :star_mascot,
      url: new_activity_session_path,
      tab_class: "tab-green",
      decoration_class: nil
    }
  end

  def latest_pending_activity_session
    current_user
      .activity_sessions
      .includes(activity: %i[interest duration])
      .where(finished: false, status: "in_progress")
      .order(updated_at: :desc)
      .first
  end

  def pending_activity_subtitle(activity_session)
    activity = activity_session.activity

    interest_name = activity_interest_name(activity)
    duration_label = activity_duration_label(activity)
    elapsed_label = elapsed_activity_label(activity_session)

    [interest_name, duration_label, elapsed_label].compact.join(" • ")
  end

  def elapsed_activity_label(activity_session)
    elapsed_seconds = activity_session.elapsed_seconds.to_i

    return if elapsed_seconds <= 0

    minutes = elapsed_seconds / 60
    seconds = elapsed_seconds % 60

    if minutes.positive?
      "#{minutes} min #{seconds.to_s.rjust(2, '0')} déjà faites"
    else
      "#{seconds}s déjà faites"
    end
  end

  def prepare_room_progress
    xp_per_activity = 15
    reward_threshold_xp = actions_needed_for_reward * xp_per_activity
    current_cycle_xp = (finished_sessions_count % actions_needed_for_reward) * xp_per_activity

    @room_xp_before_reward = reward_threshold_xp - current_cycle_xp
    @room_xp_before_reward = reward_threshold_xp if @room_xp_before_reward.zero?
  end

  def finished_sessions_count
    return @finished_sessions_count if defined?(@finished_sessions_count) && @finished_sessions_count.present?

    @finished_sessions_count = current_user
                               .activity_sessions
                               .where(finished: true)
                               .count
  end

  def actions_needed_for_reward
    3
  end

  def daily_bonus_goal
    3
  end

  def finished_sessions_today_count
    current_user
      .activity_sessions
      .where(finished: true, date: Date.current)
      .count
  end

  def current_streak_title
    streak_days = current_streak_days

    if streak_days > 1
      "#{streak_days} jours de suite"
    else
      "Belle action aujourd’hui"
    end
  end

  def current_streak_days
    finished_dates = current_user
                     .activity_sessions
                     .where(finished: true)
                     .where.not(date: nil)
                     .distinct
                     .order(date: :desc)
                     .pluck(:date)

    return 0 if finished_dates.empty?

    streak = 0
    expected_date = Date.current

    finished_dates.each do |date|
      if date == expected_date
        streak += 1
        expected_date -= 1.day
      elsif date < expected_date
        break
      end
    end

    streak
  end

  def activity_interest_name(activity)
    activity&.interest&.name.presence
  end

  def activity_duration_label(activity)
    minutes = activity&.duration&.value.to_i

    return if minutes <= 0

    "#{minutes} min"
  end
end
