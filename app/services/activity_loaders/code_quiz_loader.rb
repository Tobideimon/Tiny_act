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
        .limit(code_question_limit)
    end

    def code_difficulty
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

    def code_question_limit
      case activity.duration.value
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
  end
end
