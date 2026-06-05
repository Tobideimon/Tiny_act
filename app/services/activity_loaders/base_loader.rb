module ActivityLoaders
  class BaseLoader
    attr_reader :activity, :activity_session

    def initialize(activity:, activity_session:)
      @activity = activity
      @activity_session = activity_session
    end

    def call
      {
        duration_seconds: duration_seconds
      }
    end

    private

    def duration_seconds
      activity.duration.value * 60
    end
  end
end
