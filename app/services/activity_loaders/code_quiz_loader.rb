module ActivityLoaders
  class CodeQuizLoader < BaseLoader
    def call
      super.merge(
        code_questions_by_family: code_questions_by_family
      )
    end

    private

    def code_questions_by_family
      mood_name = activity.mood.name
      CodeQuestion::FAMILY_NAMES.index_with do |family|
        CodeQuestion
          .weighted_pool(family: family, mood_name: mood_name, limit: pool_limit)
          .map do |q|
            {
              question: q.question,
              family: q.family,
              difficulty: q.difficulty,
              correct_answer: q.correct_answer,
              answers: q.answers
            }
          end
      end
    end

    def pool_limit
      [activity.duration.value.to_i * 8, 100].min
    end
  end
end
