class Activity < ApplicationRecord
  ACTIVITY_TYPES = %w[standard word_learning sentence_completion llm_chat culture_quiz code_quiz] # rubocop:disable Lint/ConstantReassignment
  LANGUAGE_ACTIVITY_TYPES = %w[word_learning sentence_completion llm_chat]

  belongs_to :duration
  belongs_to :interest
  belongs_to :location
  belongs_to :mood

  has_many :activity_sessions, dependent: :destroy

  validates :name, presence: true
  validates :content, presence: true
  validates :activity_type, presence: true, inclusion: { in: ACTIVITY_TYPES }

  def language_activity?
    LANGUAGE_ACTIVITY_TYPES.include?(activity_type)
  end

  def culture_activity?
    activity_type == "culture_quiz"
  end

  def code_quiz?
    activity_type == "code_quiz"
  end

  def sport_activity?
    interest&.name == "Sport"
  end

  def display_description
    description.presence || content
  end

  def step_list
    return [] if steps.blank?

    steps
      .scan(/(?:^|\s)\d+\)\s*(.*?)(?=\s+\d+\)|\z)/m)
      .flatten
      .map(&:strip)
      .reject(&:blank?)
  end

  def sport_activity_plan # rubocop:disable Metrics/MethodLength
    plan = execution_plan.presence
    return normalize_sport_plan(plan) if plan.is_a?(Hash) && plan["steps"].present?

    fallback_steps = legacy_sport_step_list.map do |step|
      {
        "kind" => "exercise",
        "text" => step,
        "duration_seconds" => sport_duration_from_text(step),
        "auto_advance" => sport_duration_from_text(step).present?,
        "loop" => true
      }
    end

    normalize_sport_plan(
      "version" => 1,
      "preparation_seconds" => preparation_seconds.presence || 30,
      "target_duration_seconds" => duration.value * 60,
      "repeat_mode" => "sequence",
      "default_rest_seconds" => sport_default_rest_seconds,
      "steps" => fallback_steps
    )
  end

  def sport_step_list
    sport_activity_plan["steps"].map { |step| step["text"] }.reject(&:blank?)
  end

  private

  def normalize_sport_plan(plan)
    plan = plan.deep_stringify_keys
    plan["version"] ||= 1
    plan["preparation_seconds"] = plan["preparation_seconds"].presence || preparation_seconds.presence || 30
    plan["target_duration_seconds"] = plan["target_duration_seconds"].presence || duration.value * 60
    plan["repeat_mode"] = plan["repeat_mode"].presence || "sequence"
    plan["default_rest_seconds"] = plan["default_rest_seconds"].presence || sport_default_rest_seconds
    plan["steps"] = Array(plan["steps"]).map do |step|
      step = step.deep_stringify_keys
      step["kind"] ||= "exercise"
      step["text"] ||= "Étape"
      step["duration_seconds"] = step["duration_seconds"].presence
      step["auto_advance"] = ActiveModel::Type::Boolean.new.cast(step.fetch("auto_advance", step["duration_seconds"].present?))
      step["loop"] = ActiveModel::Type::Boolean.new.cast(step.fetch("loop", !%w[warmup cooldown instruction].include?(step["kind"])))
      step
    end
    plan
  end

  def legacy_sport_step_list
    return [] if steps.blank?

    steps
      .scan(/(?:^|\s)\d+\)\s*(.*?)(?=\s+\d+\)|\z)/m)
      .flatten
      .map(&:strip)
      .reject(&:blank?)
  end

  def sport_duration_from_text(text)
    match = text.to_s.downcase.match(/(\d+)\s*(secondes?|sec|minutes?|min)/)
    return nil unless match

    value = match[1].to_i
    unit = match[2]
    unit.start_with?("min") ? value * 60 : value
  end

  def sport_default_rest_seconds
    case duration.value
    when 0..5 then 20
    when 6..15 then 35
    else 45
    end
  end
end
