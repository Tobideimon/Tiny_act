require "net/http"
require "json"

class ApiNinjasExplorer
  TYPES = [
    "cardio",
    "plyometrics",
    "stretching"
  ]

  def call
    TYPES.each do |type|
      puts ""
      puts "===== #{type.upcase} ====="

      exercises(type).each do |exercise|
        next unless exercise["equipments"].empty?

        puts exercise["name"]
      end
    end
  end

  private

  def exercises(type)
    uri = URI("https://api.api-ninjas.com/v1/exercises?type=#{type}&offset=10")

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
