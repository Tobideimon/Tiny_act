# app/services/api_ninjas_exporter.rb

require "net/http"
require "json"
require "csv"

class ApiNinjasExporter

  MUSCLES = [
    "abdominals",
    "abductors",
    "adductors",
    "biceps",
    "calves",
    "chest",
    "forearms",
    "glutes",
    "hamstrings",
    "lats",
    "lower_back",
    "middle_back",
    "neck",
    "quadriceps",
    "traps",
    "triceps"
  ]

  def call
    exercises = []

    MUSCLES.each do |muscle|

      puts "Fetching #{muscle}..."

      fetch_exercises(muscle).each do |exercise|

        next unless exercise["equipments"].empty?

        exercises << {
          name: exercise["name"],
          type: exercise["type"],
          muscle: exercise["muscle"],
          difficulty: exercise["difficulty"],
          instructions: exercise["instructions"],
          safety_info: exercise["safety_info"]
        }
      end
    end

    exercises.uniq! { |exercise| exercise[:name] }

    export_csv(exercises)

    puts "✅ #{exercises.count} unique exercises exported"
  end

  private

  def fetch_exercises(muscle)

    uri = URI(
      "https://api.api-ninjas.com/v1/exercises?muscle=#{muscle}"
    )

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

  def export_csv(exercises)

    filepath =
      Rails.root.join(
        "tmp",
        "api_ninjas_exercises.csv"
      )

    CSV.open(filepath, "wb") do |csv|

      csv << [
        "name",
        "type",
        "muscle",
        "difficulty",
        "instructions",
        "safety_info"
      ]

      exercises.each do |exercise|

        csv << [
          exercise[:name],
          exercise[:type],
          exercise[:muscle],
          exercise[:difficulty],
          exercise[:instructions],
          exercise[:safety_info]
        ]
      end
    end

    puts "📁 File created : #{filepath}"
  end
end
