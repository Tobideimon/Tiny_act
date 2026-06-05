module ActivityLoaders
  class Factory
    def self.for(activity:, activity_session:)
      if activity.culture_activity?
        CultureLoader.new(activity: activity, activity_session: activity_session)
      elsif activity.code_quiz?
        CodeQuizLoader.new(activity: activity, activity_session: activity_session)
      elsif activity.language_activity?
        LanguageLoader.new(activity: activity, activity_session: activity_session)
      else
        BaseLoader.new(activity: activity, activity_session: activity_session)
      end
    end
  end
end
