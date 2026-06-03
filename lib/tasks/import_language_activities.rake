require "csv"

namespace :language_activities do
  desc "Import language activities from db/data/language_activities.csv"
  task import: :environment do
    path = Rails.root.join("db/data/language_activities.csv")

    unless File.exist?(path)
      puts "CSV file not found: #{path}"
      exit
    end

    puts "🧹 Cleaning language items..."
    LanguageItem.destroy_all

    puts "🌍 Importing language activities..."

    imported_count = 0

    CSV.foreach(path, headers: true) do |row|
      LanguageItem.create!(
        item_type: row["item_type"],
        prompt: row["prompt"],
        answer: row["answer"],
        translation: row["translation"].presence,
        language: row["language"]
      )

      imported_count += 1
    end

    puts "✅ Import completed!"
    puts "#{imported_count} language activities imported"
    puts "#{LanguageItem.where(language: 'english', item_type: 'word').count} English words"
    puts "#{LanguageItem.where(language: 'english', item_type: 'sentence').count} English sentences"
    puts "#{LanguageItem.where(language: 'spanish', item_type: 'word').count} Spanish words"
    puts "#{LanguageItem.where(language: 'spanish', item_type: 'sentence').count} Spanish sentences"
  end
end
