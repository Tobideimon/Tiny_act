require "csv"

namespace :culture_questions do
  desc "Import culture questions from db/data/culture_questions_fr.csv"
  task import_csv: :environment do
    path = Rails.root.join("db/data/culture_questions_fr.csv")

    unless File.exist?(path)
      puts "CSV file not found: #{path}"
      exit
    end

    required_headers = [
      "question",
      "correct_answer",
      "wrong_answer_1",
      "wrong_answer_2",
      "wrong_answer_3",
      "category",
      "difficulty",
      "source"
    ]

    csv = CSV.read(
      path,
      headers: true,
      col_sep: ",",
      quote_char: '"',
      liberal_parsing: true
    )

    missing_headers = required_headers - csv.headers

    raise "Missing CSV headers: #{missing_headers.join(', ')}" if missing_headers.any?

    puts "🧹 Cleaning culture questions..."
    CultureQuestion.destroy_all

    puts "🧠 Importing culture questions from CSV..."

    imported_count = 0

    csv.each.with_index(2) do |row, line_number|
      question = row["question"]&.strip
      correct_answer = row["correct_answer"]&.strip
      wrong_answer_1 = row["wrong_answer_1"]&.strip
      wrong_answer_2 = row["wrong_answer_2"]&.strip
      wrong_answer_3 = row["wrong_answer_3"]&.strip
      category = row["category"]&.strip
      difficulty = row["difficulty"]&.strip
      source = row["source"]&.strip

      if question.blank? || correct_answer.blank? || wrong_answer_1.blank? || wrong_answer_2.blank? || wrong_answer_3.blank? || category.blank? || difficulty.blank? || source.blank?
        raise "Import error line #{line_number}: missing data. Row: #{row.to_h}"
      end

      if CultureQuestion.exists?(question: question)
        puts "⚠️ Duplicate question skipped line #{line_number}: #{question}"
        next
      end

      CultureQuestion.create!(
        question: question,
        correct_answer: correct_answer,
        wrong_answer_1: wrong_answer_1,
        wrong_answer_2: wrong_answer_2,
        wrong_answer_3: wrong_answer_3,
        category: category,
        difficulty: difficulty,
        source: source
      )

      imported_count += 1
    end

    puts "✅ Culture CSV import completed!"
    puts "#{imported_count} culture questions imported"
    puts "#{CultureQuestion.where(difficulty: 'easy').count} easy"
    puts "#{CultureQuestion.where(difficulty: 'medium').count} medium"
    puts "#{CultureQuestion.where(difficulty: 'hard').count} hard"
  end
end
