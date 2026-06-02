class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  def show
    @activity = Activity.find(params[:id])
    @activity_session = current_user.activity_sessions.find_by(id: params[:activity_session_id])

    unless @activity_session
      redirect_to root_path, alert: "Session introuvable."
      return
    end

    @activity_session.update!(activity: @activity)

    @duration_seconds = @activity.duration.value * 60

    return unless @activity.language_activity?

    assign_language_if_needed
    @language_label = readable_language(@activity_session.language)
    load_language_items
  end

  private

  def assign_language_if_needed
    return if @activity_session.language.present?

    item_type = language_item_type_for(@activity)

    language = LanguageItem
               .where(item_type: item_type)
               .distinct
               .pluck(:language)
               .sample

    @activity_session.update!(language: language) if language.present?
  end

  def load_language_items
    item_type = language_item_type_for(@activity)

    return if item_type.blank? || @activity_session.language.blank?

    @language_items = LanguageItem
                      .where(item_type: item_type, language: @activity_session.language)
                      .order(Arel.sql("RANDOM()"))
                      .limit(100)
  end

  def language_item_type_for(activity)
    case activity.activity_type
    when "word_learning"
      "word"
    when "sentence_completion"
      "sentence"
    end
  end

  def readable_language(language)
    {
      "english" => "anglais",
      "spanish" => "espagnol"
    }[language]
  end
end
