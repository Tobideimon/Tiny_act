class ActivitySession < ApplicationRecord
  LANGUAGES = %w[english spanish]
  STATUSES = %w[selecting in_progress finished abandoned]

  belongs_to :user
  belongs_to :activity

  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :language, inclusion: { in: LANGUAGES }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }

  def in_progress?
    status == "in_progress" && !finished?
  end

  def finished_status?
    status == "finished" || finished?
  end

  def resume_path
    Rails.application.routes.url_helpers.activity_path(
      activity,
      activity_session_id: id
    )
  end

  def duration_seconds
    activity.duration.value.to_i * 60
  end

  def remaining_seconds
    [duration_seconds - elapsed_seconds.to_i, 0].max
  end
end
