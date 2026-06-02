# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

puts "🧹 Cleaning database..."

ActivitySession.destroy_all
UserInterest.destroy_all
Activity.destroy_all

Interest.destroy_all
Mood.destroy_all
Location.destroy_all
Duration.destroy_all

User.destroy_all

puts "😊 Creating moods..."

en_forme = Mood.create!(name: "En forme")
mitige   = Mood.create!(name: "Mitigé")
a_plat   = Mood.create!(name: "À plat")

puts "⏱ Creating durations..."

five_minutes     = Duration.create!(value: 5)
fifteen_minutes  = Duration.create!(value: 15)
thirty_minutes   = Duration.create!(value: 30)

puts "📍 Creating locations..."

home     = Location.create!(name: "Maison")
outside  = Location.create!(name: "Extérieur")
transport   = Location.create!(name: "Transport")

puts "🎯 Creating interests..."

sport      = Interest.create!(name: "Sport")
creative   = Interest.create!(name: "Créativité")
wellbeing  = Interest.create!(name: "Bien-être")

puts "🏃 Creating activities..."

squats = Activity.create!(
  name: "30 squats",
  content: "Fais 30 squats à ton rythme pour te mettre en mouvement.",
  mood: en_forme,
  location: home,
  duration: five_minutes,
  interest: sport
)

jumping_jacks = Activity.create!(
  name: "50 jumping jacks",
  content: "Réalise 50 jumping jacks à ton rythme. L'objectif est d'activer tout le corps et de faire monter légèrement le cardio en quelques minutes.",
  mood: en_forme,
  location: home,
  duration: five_minutes,
  interest: sport
)

walk = Activity.create!(
  name: "Marche rapide",
  content: "Pars marcher d'un bon pas pendant 15 minutes. Observe ton environnement et essaie de maintenir un rythme soutenu pendant toute la durée.",
  mood: en_forme,
  location: home,
  duration: five_minutes,
  interest: sport
)

photo = Activity.create!(
  name: "Photo insolite",
  content: "Prends une photo de quelque chose que tu n'avais jamais remarqué autour de toi.",
  mood: mitige,
  location: outside,
  duration: fifteen_minutes,
  interest: creative
)

breathing = Activity.create!(
  name: "Respiration guidée",
  content: "Prends 5 minutes pour respirer profondément et te recentrer.",
  mood: a_plat,
  location: transport,
  duration: five_minutes,
  interest: wellbeing
)

puts "👤 Creating users..."

alex = User.create!(
  first_name: "Alex",
  last_name: "Martin",
  email: "alex@tinyact.com",
  password: "123456"
)

lea = User.create!(
  first_name: "Léa",
  last_name: "Dubois",
  email: "lea@tinyact.com",
  password: "123456"
)

sam = User.create!(
  first_name: "Sam",
  last_name: "Bernard",
  email: "sam@tinyact.com",
  password: "123456"
)

puts "❤️ Creating user interests..."

UserInterest.create!(
  user: alex,
  interest: sport
)

UserInterest.create!(
  user: lea,
  interest: creative
)

UserInterest.create!(
  user: sam,
  interest: wellbeing
)

load Rails.root.join("db/seeds/sport_seed.rb")

puts "✅ Seed completed!"

puts "#{User.count} users created"
puts "#{Interest.count} interests created"
puts "#{Activity.count} activities created"
