module ActivityLoaders
  class CultureLoader < BaseLoader
    def call
      super.merge(
        culture_questions: culture_questions
      )
    end

    private

    def culture_questions
      CultureQuestion
        .where(difficulty: culture_difficulty)
        .order(Arel.sql("RANDOM()"))
        .limit(300)
    end

    def culture_difficulty
      case activity.mood.name
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
  end
end
