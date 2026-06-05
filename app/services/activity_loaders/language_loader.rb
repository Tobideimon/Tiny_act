module ActivityLoaders
  class LanguageLoader < BaseLoader
    def call
      assign_language_if_needed

      super.merge(
        language_label: readable_language(activity_session.language),
        language_items: language_items
      )
    end

    private

    def assign_language_if_needed
      return if activity_session.language.present?

      item_type = language_item_type_for(activity)

      language = LanguageItem
                 .where(item_type: item_type)
                 .distinct
                 .pluck(:language)
                 .sample

      activity_session.update!(language: language) if language.present?
    end

    def language_items
      item_type = language_item_type_for(activity)

      return LanguageItem.none if item_type.blank? || activity_session.language.blank?

      LanguageItem
        .where(item_type: item_type, language: activity_session.language)
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
end
