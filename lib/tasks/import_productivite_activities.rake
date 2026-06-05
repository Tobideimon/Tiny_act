require "csv"

namespace :productivite_activities do
  desc "Import productivité activities from db/data/productivite_activities.csv"
  task import: :environment do
    path = Rails.root.join("db/data/productivite_activities.csv")
    unless File.exist?(path)
      puts "CSV file not found: #{path}"
      exit
    end

    # interest = Interest.find_or_create_by!(name: "Productivité")
    puts "🗂  Importing productivité activities..."
    imported_count = 0
    updated_count = 0

    CSV.foreach(path, headers: true, col_sep: ";").with_index(2) do |row, line_number|
      name          = row["name"]&.strip
      content       = row["content"]&.strip
      mood_name     = row["mood"]&.strip
      location_name = row["location"]&.strip
      duration_value = row["duration"].to_i

      if name.blank? || content.blank? || mood_name.blank? || location_name.blank? || duration_value.zero?
        raise "Import error line #{line_number}: missing data. Row: #{row.to_h}"
      end

      mood     = Mood.find_by(name: mood_name)
      location = Location.find_by(name: location_name)
      duration = Duration.find_by(value: duration_value)

      unless mood && location && duration
        raise "Import error line #{line_number}: mood/location/duration not found. Row: #{row.to_h}"
      end

      activity = Activity.find_or_initialize_by(
        name: name,
        interest: interest,
        mood: mood,
        location: location,
        duration: duration
      )
      activity.content       = content
      activity.description   = row["description"]&.strip
      activity.steps         = row["steps"]&.strip
      activity.activity_type = "standard"
      activity.active        = true

      activity.new_record? ? (imported_count += 1) : (updated_count += 1)
      activity.save!
    end

    puts "✅ Productivité import completed!"
    puts "#{imported_count} created, #{updated_count} updated."
    puts "#{Activity.where(interest: interest).count} productivité activities in database."
  end
end
