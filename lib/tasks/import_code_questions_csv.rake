require "csv"

# Regroupe les 19 thèmes du CSV en 4 familles : sélecteur plus dense et lisible.
def code_quiz_family_for(category)
  case category.to_s
  when /Ruby|Rails/          then "Ruby / Rails"
  when /HTML|CSS|JavaScript/ then "Front (HTML / CSS / JS)"
  when /\AIA/                then "IA"
  else                            "Données & Outils"
  end
end

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
    CodeQuestion.destroy_all # sûr : table dédiée, n'affecte pas le culture
    puts "💻 Importing code questions from CSV..."
    imported_count = 0
    csv.each.with_index(2) do |row, line_number|
      question       = row["question"]&.strip
      correct_answer = row["correct_answer"]&.strip
      wrong_answer_1 = row["wrong_answer_1"]&.strip
      wrong_answer_2 = row["wrong_answer_2"]&.strip
      wrong_answer_3 = row["wrong_answer_3"]&.strip
      category       = row["category"]&.strip
      difficulty     = row["difficulty"]&.strip
      source         = row["source"]&.strip
      if [question, correct_answer, wrong_answer_1, wrong_answer_2, wrong_answer_3, category, difficulty].any?(&:blank?)
        raise "Import error line #{line_number}: missing data. Row: #{row.to_h}"
      end
      next if CodeQuestion.exists?(question: question)

      CodeQuestion.create!(
        question: question, correct_answer: correct_answer,
        wrong_answer_1: wrong_answer_1, wrong_answer_2: wrong_answer_2, wrong_answer_3: wrong_answer_3,
        category: code_quiz_family_for(category), difficulty: difficulty, source: source
      )
      imported_count += 1
    end
    puts "✅ Code questions import completed!"
    puts "#{imported_count} importées | #{CodeQuestion.where(difficulty: 'easy').count} easy / #{CodeQuestion.where(difficulty: 'medium').count} medium / #{CodeQuestion.where(difficulty: 'hard').count} hard"
  end
end
