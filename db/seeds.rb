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
LanguageItem.destroy_all

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

five_minutes    = Duration.create!(value: 5)
fifteen_minutes = Duration.create!(value: 15)
thirty_minutes  = Duration.create!(value: 30)

puts "📍 Creating locations..."

home     = Location.create!(name: "Maison")
outside  = Location.create!(name: "Extérieur")
office   = Location.create!(name: "Bureau")
anywhere = Location.create!(name: "N'importe où")

puts "🎯 Creating interests..."

sport          = Interest.create!(name: "Sport")
creative       = Interest.create!(name: "Créativité")
wellbeing      = Interest.create!(name: "Bien-être")
photo_interest = Interest.create!(name: "Photo")
drawing        = Interest.create!(name: "Dessin")
writing        = Interest.create!(name: "Écriture")
languages      = Interest.create!(name: "Langues")
culture        = Interest.create!(name: "Culture")

puts "🏃 Creating activities..."

Activity.create!(
  name: "30 squats",
  content: "Fais 30 squats à ton rythme pour te mettre en mouvement.",
  mood: en_forme,
  location: home,
  duration: five_minutes,
  interest: sport,
  activity_type: "standard"
)

Activity.create!(
  name: "50 jumping jacks",
  content: "Réalise 50 jumping jacks à ton rythme. L'objectif est d'activer tout le corps et de faire monter légèrement le cardio en quelques minutes.",
  mood: en_forme,
  location: home,
  duration: five_minutes,
  interest: sport,
  activity_type: "standard"
)

Activity.create!(
  name: "Marche rapide",
  content: "Pars marcher d'un bon pas pendant 15 minutes. Observe ton environnement et essaie de maintenir un rythme soutenu pendant toute la durée.",
  mood: en_forme,
  location: outside,
  duration: fifteen_minutes,
  interest: sport,
  activity_type: "standard"
)

Activity.create!(
  name: "Photo insolite",
  content: "Prends une photo de quelque chose que tu n'avais jamais remarqué autour de toi.",
  mood: mitige,
  location: outside,
  duration: fifteen_minutes,
  interest: photo_interest,
  activity_type: "standard"
)

Activity.create!(
  name: "Respiration guidée",
  content: "Prends 5 minutes pour respirer profondément et te recentrer.",
  mood: a_plat,
  location: office,
  duration: five_minutes,
  interest: wellbeing,
  activity_type: "standard"
)

puts "🌍 Creating language activities..."

Activity.create!(
  name: "Apprendre quelques mots",
  content: "Découvre des mots simples dans une langue choisie au hasard. Lis-les, répète-les, puis essaie de retenir leur traduction.",
  mood: a_plat,
  location: anywhere,
  duration: five_minutes,
  interest: languages,
  activity_type: "word_learning"
)

Activity.create!(
  name: "Apprendre quelques mots",
  content: "Prends un moment calme pour apprendre plusieurs mots dans une langue choisie au hasard.",
  mood: a_plat,
  location: anywhere,
  duration: fifteen_minutes,
  interest: languages,
  activity_type: "word_learning"
)

Activity.create!(
  name: "Apprendre quelques mots",
  content: "Découvre quelques mots simples dans une langue choisie au hasard.",
  mood: mitige,
  location: anywhere,
  duration: five_minutes,
  interest: languages,
  activity_type: "word_learning"
)

Activity.create!(
  name: "Compléter des phrases",
  content: "Complète des phrases simples avec le bon mot dans une langue choisie au hasard.",
  mood: mitige,
  location: anywhere,
  duration: fifteen_minutes,
  interest: languages,
  activity_type: "sentence_completion"
)

Activity.create!(
  name: "Compléter des phrases",
  content: "Prends le temps de compléter plusieurs phrases simples avec les bons mots.",
  mood: mitige,
  location: anywhere,
  duration: thirty_minutes,
  interest: languages,
  activity_type: "sentence_completion"
)

Activity.create!(
  name: "Dialogue guidé",
  content: "Pratique une courte conversation dans une langue choisie au hasard.",
  mood: en_forme,
  location: anywhere,
  duration: five_minutes,
  interest: languages,
  activity_type: "llm_chat"
)

Activity.create!(
  name: "Dialogue guidé",
  content: "Pratique une conversation simple avec un assistant dans une langue choisie au hasard.",
  mood: en_forme,
  location: anywhere,
  duration: fifteen_minutes,
  interest: languages,
  activity_type: "llm_chat"
)

Activity.create!(
  name: "Dialogue guidé",
  content: "Lance une conversation plus longue pour pratiquer une langue avec un assistant.",
  mood: en_forme,
  location: anywhere,
  duration: thirty_minutes,
  interest: languages,
  activity_type: "llm_chat"
)

puts "🌍 Creating language items..."

LanguageItem.create!(
  item_type: "word",
  prompt: "house",
  answer: "maison",
  language: "english"
)

LanguageItem.create!(
  item_type: "word",
  prompt: "window",
  answer: "fenêtre",
  language: "english"
)

LanguageItem.create!(
  item_type: "word",
  prompt: "water",
  answer: "eau",
  language: "english"
)

LanguageItem.create!(
  item_type: "sentence",
  prompt: "I ___ tired.",
  answer: "am",
  translation: "Je suis fatigué.",
  language: "english"
)

LanguageItem.create!(
  item_type: "sentence",
  prompt: "She ___ a book.",
  answer: "has",
  translation: "Elle a un livre.",
  language: "english"
)

LanguageItem.create!(
  item_type: "word",
  prompt: "casa",
  answer: "maison",
  language: "spanish"
)

LanguageItem.create!(
  item_type: "word",
  prompt: "agua",
  answer: "eau",
  language: "spanish"
)

LanguageItem.create!(
  item_type: "word",
  prompt: "ventana",
  answer: "fenêtre",
  language: "spanish"
)

LanguageItem.create!(
  item_type: "sentence",
  prompt: "Estoy ___ casa.",
  answer: "en",
  translation: "Je suis à la maison.",
  language: "spanish"
)

LanguageItem.create!(
  item_type: "sentence",
  prompt: "Tengo ___ libro.",
  answer: "un",
  translation: "J’ai un livre.",
  language: "spanish"
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

emma = User.create!(
  first_name: "Emma",
  last_name: "Lopez",
  email: "emma@tinyact.com",
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

UserInterest.create!(
  user: emma,
  interest: languages
)

puts "✅ Seed completed!"

puts "#{User.count} users created"
puts "#{Interest.count} interests created"
puts "#{Location.count} locations created"
puts "#{Duration.count} durations created"
puts "#{Activity.count} activities created"
puts "#{LanguageItem.count} language items created"

puts "#{Activity.where(interest: languages).count} language activities created"
puts "#{Activity.where(activity_type: "word_learning").count} word learning activities created"
puts "#{Activity.where(activity_type: "sentence_completion").count} sentence completion activities created"
puts "#{Activity.where(activity_type: "llm_chat").count} LLM chat activities created"
