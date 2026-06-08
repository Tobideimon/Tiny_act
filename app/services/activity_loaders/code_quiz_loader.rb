module ActivityLoaders
  class CodeQuizLoader < BaseLoader
    def call
      super.merge(
        code_questions: code_questions
      )
    end

    private

    def code_questions
      CodeQuestion
        .where(difficulty: code_difficulty)
        .order(Arel.sql("RANDOM()"))
        .limit(100)
    end

    def code_difficulty
      case activity.mood.name
      when "À plat"
        "easy"
      when "Bof", "Mitigé"
        "medium"
      when "En forme"
        "hard"
      else
        "easy"
      end
    end
  end
end
