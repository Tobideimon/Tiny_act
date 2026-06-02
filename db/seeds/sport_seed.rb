require_relative "../sport_exercices.rb"

puts "🏃 Creating sport activities..."

sport_interest = Interest.find_by!(name: "Sport")

SPORT_EXERCISES.each do |exercise|

  [5, 15, 30].each do |duration_value|

    Activity.find_or_create_by!(
      name: "#{exercise[:name]} - #{duration_value} min"
    ) do |activity|

      activity.content =
        "Réalise l'exercice #{exercise[:name]} pendant #{duration_value} minutes."

      activity.interest = sport_interest

      activity.mood =
        Mood.find_by!(name: exercise[:mood])

      activity.location =
        Location.find_by!(name: exercise[:location])

      activity.duration =
        Duration.find_by!(value: duration_value)
    end
  end
end

puts "✅ #{Activity.where(interest: sport_interest).count} sport activities available"
