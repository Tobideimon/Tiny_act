require "csv"

namespace :culture_questions do
  desc "Export culture questions to db/data/culture_questions_en.csv"
  task export: :environment do
    path = Rails.root.join("db/data/culture_questions_en.csv")

    puts "📤 Exporting culture questions..."

    CSV.open(path, "w", headers: true, col_sep: ";") do |csv|
      csv << [
        "question",
        "correct_answer",
        "wrong_answer_1",
        "wrong_answer_2",
        "wrong_answer_3",
        "category",
        "difficulty",
        "source"
      ]

      CultureQuestion.order(:difficulty, :category, :id).find_each do |question|
        csv << [
          question.question,
          question.correct_answer,
          question.wrong_answer_1,
          question.wrong_answer_2,
          question.wrong_answer_3,
          question.category,
          question.difficulty,
          question.source
        ]
      end
    end

    puts "✅ Export completed!"
    puts "#{CultureQuestion.count} questions exported"
    puts "File created: #{path}"
  end
end
