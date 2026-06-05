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

    if @activity.culture_activity?
      load_culture_quiz
      return
    end

    if @activity.code_quiz?
      load_code_quiz
      return
    end

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

  def load_culture_quiz
    @culture_questions = CultureQuestion
                         .where(difficulty: culture_difficulty)
                         .order(Arel.sql("RANDOM()"))
                         .limit(300)
  end

  def culture_difficulty
    case @activity.mood.name
    when "À plat"
      "easy"
    when "Mitigé"
      "medium"
    when "En forme"
      "hard"
    else
      "easy"
    end
  end

  def culture_question_limit
    case @activity.duration.value
    when 5
      10
    when 15
      24
    when 30
      40
    else
      10
    end
  end

  def load_code_quiz
    @code_questions = CodeQuestion
                      .where(difficulty: code_difficulty)
                      .order(Arel.sql("RANDOM()"))
  end

  def code_difficulty
    case @activity.mood.name
    when "À plat"  then "easy"
    when "Mitigé"  then "medium"
    when "En forme" then "hard"
    else "easy"
    end
  end

  def code_question_limit
    case @activity.duration.value
    when 5  then 10
    when 15 then 24
    when 30 then 40
    else 10
    end
  end
end
