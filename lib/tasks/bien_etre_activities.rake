require "csv"
require "json"

namespace :bien_etre_activities do
  desc "Import bien-être activities from db/data/bien_etre_activities.csv"
  task import: :environment do
    path = Rails.root.join("db/data/bien_etre_activities.csv")

    unless File.exist?(path)
      puts "CSV file not found: #{path}"
      exit
    end

    wellbeing = Interest.find_or_create_by!(name: "Bien-être")

    puts "🧹 Cleaning old bien-être activities..."
    Activity.where(interest: wellbeing).destroy_all

    puts "🧘 Importing bien-être activities..."

    imported_count = 0

    CSV.foreach(path, headers: true, col_sep: ";").with_index(2) do |row, line_number|
      name = row["name"]&.strip
      content = row["content"]&.strip
      description = row["description"]&.strip
      steps = row["steps"]&.strip
      mood_name = row["mood"]&.strip
      location_name = row["location"]&.strip
      duration_value = row["duration"].to_i
      preparation_seconds = row["preparation_seconds"].presence&.to_i || 30
      execution_plan = parse_execution_plan(row["execution_plan"], line_number)

      if name.blank? || content.blank? || mood_name.blank? || location_name.blank? || duration_value.zero?
        raise "Import error line #{line_number}: missing data. Row: #{row.to_h}"
      end

      mood = Mood.find_by!(name: mood_name)
      location = Location.find_by!(name: location_name)
      duration = Duration.find_by!(value: duration_value)

      Activity.create!(
        name: name,
        content: content,
        description: description,
        steps: steps,
        mood: mood,
        location: location,
        duration: duration,
        interest: wellbeing,
        activity_type: "standard",
        preparation_seconds: preparation_seconds,
        execution_plan: execution_plan,
        active: true
      )

      imported_count += 1
    end

    puts "✅ Bien-être import completed!"
    puts "#{imported_count} bien-être activities created."
  end

  def parse_execution_plan(raw_json, line_number)
    return {} if raw_json.blank?

    JSON.parse(raw_json)
  rescue JSON::ParserError => e
    raise "Import error line #{line_number}: invalid execution_plan JSON: #{e.message}"
  end
end
