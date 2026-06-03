require "csv"

namespace :sport_activities do
  desc "Import sport activities from db/data/sport_activities.csv"
  task import: :environment do
    path = Rails.root.join("db/data/sport_activities.csv")

    unless File.exist?(path)
      puts "CSV file not found: #{path}"
      exit
    end

    sport = Interest.find_or_create_by!(name: "Sport")

    puts "🏃 Importing sport activities..."

    imported_count = 0
    updated_count = 0

    CSV.foreach(path, headers: true, col_sep: ";").with_index(2) do |row, line_number|
      name = row["name"]&.strip
      content = row["content"]&.strip
      description = row["description"]&.strip
      steps = row["steps"]&.strip
      mood_name = row["mood"]&.strip
      location_name = row["location"]&.strip
      duration_value = row["duration"].to_i

      if name.blank? || content.blank? || mood_name.blank? || location_name.blank? || duration_value.zero?
        raise "Import error line #{line_number}: missing data. Row: #{row.to_h}"
      end

      mood = Mood.find_by(name: mood_name)
      location = Location.find_by(name: location_name)
      duration = Duration.find_by(value: duration_value)

      unless mood && location && duration
        raise "Import error line #{line_number}: mood/location/duration not found. Row: #{row.to_h}"
      end

      activity = Activity.find_or_initialize_by(
        name: name,
        interest: sport
      )

      activity.content = content
      activity.description = description
      activity.steps = steps
      activity.mood = mood
      activity.location = location
      activity.duration = duration
      activity.activity_type = "standard"
      activity.active = true

      if activity.new_record?
        imported_count += 1
      else
        updated_count += 1
      end

      activity.save!
    end

    puts "✅ Sport import completed!"
    puts "#{imported_count} sport activities created."
    puts "#{updated_count} sport activities updated."
    puts "#{Activity.where(interest: sport).count} sport activities in database."
  end
end
