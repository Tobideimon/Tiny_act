require "csv"

namespace :code_questions do
  desc "Import code questions from db/data/webdev_ia_questions.csv"
  task import_csv: :environment do
    path = Rails.root.join("db/data/webdev_ia_questions.csv")
    unless File.exist?(path)
      puts "CSV file not found: #{path}"
      exit
    end

    csv = CSV.read(path, headers: true, col_sep: ",", quote_char: '"', liberal_parsing: true)
    puts "🧹 Cleaning code questions..."
    CodeQuestion.destroy_all

    puts "💻 Importing code questions from CSV..."
    imported_count = 0

    csv.each.with_index(2) do |row, line_number|
      attrs = {
        question:       row["question"]&.strip,
        correct_answer: row["correct_answer"]&.strip,
        wrong_answer_1: row["wrong_answer_1"]&.strip,
        wrong_answer_2: row["wrong_answer_2"]&.strip,
        wrong_answer_3: row["wrong_answer_3"]&.strip,
        category:       row["category"]&.strip,
        difficulty:     row["difficulty"]&.strip,
        topic:          row["topic"]&.strip,
        source:         row["source"]&.strip
      }

      required = attrs.values_at(:question, :correct_answer, :wrong_answer_1,
                                 :wrong_answer_2, :wrong_answer_3, :category, :difficulty)
      raise "Import error line #{line_number}: missing data. Row: #{row.to_h}" if required.any?(&:blank?)

      attrs[:family] = CodeQuestion::FAMILIES.fetch(attrs[:category], "Données & Outils")
      CodeQuestion.create!(attrs)
      imported_count += 1
    end

    puts "✅ #{imported_count} importées | " \
         "#{CodeQuestion.where(difficulty: 'easy').count} easy / " \
         "#{CodeQuestion.where(difficulty: 'medium').count} medium / " \
         "#{CodeQuestion.where(difficulty: 'hard').count} hard"
  end
end
