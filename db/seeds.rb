puts "🧹 Cleaning database..."

ActivitySession.destroy_all
UserInterest.destroy_all
Activity.destroy_all
LanguageItem.destroy_all

User.destroy_all
Interest.destroy_all
Mood.destroy_all
Location.destroy_all
Duration.destroy_all

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

puts "🌍 Creating language activities..."

Activity.create!(
  name: "Apprendre quelques mots",
  content: "Découvre des mots simples dans une langue choisie au hasard. Lis-les, répète-les, puis essaie de retenir leur traduction.",
  mood: a_plat,
  location: anywhere,
  duration: five_minutes,
  interest: languages,
  activity_type: "word_learning",
  active: true
)

Activity.create!(
  name: "Apprendre quelques mots",
  content: "Prends un moment calme pour apprendre plusieurs mots dans une langue choisie au hasard.",
  mood: a_plat,
  location: anywhere,
  duration: fifteen_minutes,
  interest: languages,
  activity_type: "word_learning",
  active: true
)

Activity.create!(
  name: "Apprendre quelques mots",
  content: "Découvre quelques mots simples dans une langue choisie au hasard.",
  mood: mitige,
  location: anywhere,
  duration: five_minutes,
  interest: languages,
  activity_type: "word_learning",
  active: true
)

Activity.create!(
  name: "Compléter des phrases",
  content: "Complète des phrases simples avec le bon mot dans une langue choisie au hasard.",
  mood: mitige,
  location: anywhere,
  duration: fifteen_minutes,
  interest: languages,
  activity_type: "sentence_completion",
  active: true
)

Activity.create!(
  name: "Compléter des phrases",
  content: "Prends le temps de compléter plusieurs phrases simples avec les bons mots.",
  mood: mitige,
  location: anywhere,
  duration: thirty_minutes,
  interest: languages,
  activity_type: "sentence_completion",
  active: true
)

Activity.create!(
  name: "Dialogue guidé",
  content: "Pratique une courte conversation dans une langue choisie au hasard.",
  mood: en_forme,
  location: anywhere,
  duration: five_minutes,
  interest: languages,
  activity_type: "llm_chat",
  active: false
)

Activity.create!(
  name: "Dialogue guidé",
  content: "Pratique une conversation simple avec un assistant dans une langue choisie au hasard.",
  mood: en_forme,
  location: anywhere,
  duration: fifteen_minutes,
  interest: languages,
  activity_type: "llm_chat",
  active: false
)

Activity.create!(
  name: "Dialogue guidé",
  content: "Lance une conversation plus longue pour pratiquer une langue avec un assistant.",
  mood: en_forme,
  location: anywhere,
  duration: thirty_minutes,
  interest: languages,
  activity_type: "llm_chat",
  active: false
)

puts "🧘 Creating non-sport demo activities..."

Activity.create!(
  name: "Photo insolite",
  content: "Prends une photo de quelque chose que tu n'avais jamais remarqué autour de toi.",
  mood: mitige,
  location: outside,
  duration: fifteen_minutes,
  interest: photo_interest,
  activity_type: "standard",
  active: true
)

Activity.create!(
  name: "Respiration guidée",
  content: "Prends 5 minutes pour respirer profondément et te recentrer.",
  mood: a_plat,
  location: office,
  duration: five_minutes,
  interest: wellbeing,
  activity_type: "standard",
  active: true
)

puts "👤 Creating demo users..."

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

puts "❤️ Creating demo user interests..."

UserInterest.create!(user: alex, interest: sport)
UserInterest.create!(user: lea, interest: photo_interest)
UserInterest.create!(user: sam, interest: wellbeing)
UserInterest.create!(user: emma, interest: languages)

puts "🌍 Importing language items from CSV..."
Rake::Task["language_activities:import"].invoke

puts "🏃 Importing sport activities from CSV..."
Rake::Task["sport_activities:import"].invoke

puts "✅ Seed completed!"

puts "#{User.count} users created"
puts "#{Interest.count} interests created"
puts "#{Location.count} locations created"
puts "#{Duration.count} durations created"
puts "#{Activity.count} activities created"
puts "#{LanguageItem.count} language items created"

puts "#{Activity.where(interest: sport, active: true).count} active sport activities created"
puts "#{Activity.where(interest: languages, active: true).count} active language activities created"
puts "#{Activity.where(activity_type: "word_learning", active: true).count} word learning activities created"
puts "#{Activity.where(activity_type: "sentence_completion", active: true).count} sentence completion activities created"
puts "#{Activity.where(activity_type: "llm_chat", active: false).count} inactive LLM chat activities created"
