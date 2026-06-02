require "net/http"
require "json"

class ApiNinjasScout
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
    all_exercises = []

    MUSCLES.each do |muscle|
      puts "Scanning #{muscle}..."

      exercises(muscle).each do |exercise|
        next unless exercise["equipments"].empty?

        all_exercises << exercise["name"]
      end
    end

    unique_exercises = all_exercises.uniq.sort

    puts ""
    puts "========== RESULT =========="
    puts "Unique exercises: #{unique_exercises.count}"
    puts ""

    unique_exercises.each do |exercise|
      puts exercise
    end

    unique_exercises
  end

  private

  def exercises(muscle)
    uri = URI("https://api.api-ninjas.com/v1/exercises?muscle=#{muscle}")

    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = ENV.fetch("API_NINJAS_KEY", nil)

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end
end
