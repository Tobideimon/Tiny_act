require "net/http"
require "json"

class ApiNinjasImporter

  TYPES = [
    "cardio",
    "plyometrics",
    "stretching"
  ]

 def call
  count = 0

  TYPES.each do |type|
    puts "Importing #{type}..."

    exercises(type).each do |exercise|

      next unless exercise["equipments"].empty?
      next if exercise["instructions"].blank?

      create_activity(exercise, type)

      count += 1
    end
  end

  puts "#{count} activities imported"
end

  private

  def exercises(type)
    uri = URI("https://api.api-ninjas.com/v1/exercises?type=#{type}")

    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = ENV["API_NINJAS_KEY"]

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def create_activity(exercise, type)

    Activity.find_or_create_by!(
      name: exercise["name"]
    ) do |activity|

      activity.content = exercise["instructions"]

      activity.interest = Interest.find_by(name: "Sport")

      activity.mood = mood_for(type)

      activity.location = location_for(exercise)

      activity.duration = duration_for(exercise)
    end
  end

  def mood_for(type)

    case type
    when "cardio", "plyometrics"
      Mood.find_by(name: "En forme")

    when "stretching"
      Mood.find_by(name: "À plat")

    else
      Mood.find_by(name: "Mitigé")
    end
  end

  def location_for(exercise)

    if exercise["name"].match?(/jog/i)
      Location.find_by!(name: "Extérieur")
    else
      Location.find_by!(name: "Maison")
    end
  end

  def duration_for(exercise)

    case exercise["difficulty"]

    when "beginner"
      Duration.find_by(value: 5)

    when "intermediate"
      Duration.find_by(value: 15)

    else
      Duration.find_by(value: 30)
    end
  end
end
