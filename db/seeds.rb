require "csv"

puts "🧹 Cleaning database..."

ActivitySession.destroy_all
UserInterest.destroy_all
Activity.destroy_all
LanguageItem.destroy_all
CultureQuestion.destroy_all if defined?(CultureQuestion)
RoomFurniture.destroy_all
Furniture.destroy_all
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
productivite   = Interest.create!(name: "Productivité")
code           = Interest.create!(name: "Code")

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

puts "🧠 Creating culture quiz activities..."

[
  {
    mood: a_plat,
    duration: five_minutes,
    content: "Réponds à quelques questions simples pour réveiller doucement ta curiosité."
  },
  {
    mood: a_plat,
    duration: fifteen_minutes,
    content: "Installe-toi tranquillement et teste ta culture générale avec des questions accessibles."
  },
  {
    mood: a_plat,
    duration: thirty_minutes,
    content: "Prends ton temps pour explorer plusieurs questions de culture générale sans pression."
  },
  {
    mood: mitige,
    duration: five_minutes,
    content: "Challenge rapide : quelques questions pour stimuler ton esprit sans te fatiguer."
  },
  {
    mood: mitige,
    duration: fifteen_minutes,
    content: "Teste tes connaissances avec un quiz équilibré, ni trop facile ni trop intense."
  },
  {
    mood: mitige,
    duration: thirty_minutes,
    content: "Plonge dans un quiz plus complet pour entraîner ta mémoire et ta logique."
  },
  {
    mood: en_forme,
    duration: five_minutes,
    content: "Défi express : affronte quelques questions plus exigeantes."
  },
  {
    mood: en_forme,
    duration: fifteen_minutes,
    content: "Teste-toi avec un quiz plus relevé et garde le rythme."
  },
  {
    mood: en_forme,
    duration: thirty_minutes,
    content: "Lance-toi dans une vraie session de culture générale avec des questions plus ambitieuses."
  }
].each do |activity_data|
  Activity.create!(
    name: "Quiz culture générale",
    content: activity_data[:content],
    mood: activity_data[:mood],
    location: anywhere,
    duration: activity_data[:duration],
    interest: culture,
    activity_type: "culture_quiz",
    active: true
  )
end

puts "💻 Creating code quiz activities..."

[
  { mood: en_forme, duration: five_minutes },
  { mood: en_forme, duration: fifteen_minutes },
  { mood: en_forme, duration: thirty_minutes },
  { mood: mitige,   duration: five_minutes },
  { mood: mitige,   duration: fifteen_minutes },
  { mood: mitige,   duration: thirty_minutes },
  { mood: a_plat,   duration: five_minutes },
  { mood: a_plat,   duration: fifteen_minutes },
  { mood: a_plat,   duration: thirty_minutes }
].each do |data|
  Activity.create!(
    name: "Quiz code",
    content: "Teste tes connaissances en développement web et IA.",
    mood: data[:mood],
    location: anywhere,
    duration: data[:duration],
    interest: code,
    activity_type: "code_quiz",
    active: true
  )
end

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

nora = User.create!(
  first_name: "Nora",
  last_name: "Morel",
  email: "nora@tinyact.com",
  password: "123456"
)

max = User.create!(
  first_name: "Max",
  last_name: "Petit",
  email: "max@tinyact.com",
  password: "123456"
)

puts "❤️ Creating demo user interests..."

UserInterest.create!(user: alex, interest: sport)

UserInterest.create!(user: lea, interest: photo_interest)
UserInterest.create!(user: lea, interest: creative)

UserInterest.create!(user: sam, interest: wellbeing)

UserInterest.create!(user: emma, interest: languages)
UserInterest.create!(user: emma, interest: culture)

UserInterest.create!(user: nora, interest: culture)

UserInterest.create!(user: max, interest: sport)
UserInterest.create!(user: max, interest: languages)
UserInterest.create!(user: max, interest: culture)

puts "🌍 Importing language items from CSV..."
Rake::Task["language_activities:import"].invoke

puts "🏃 Importing sport activities from CSV..."
Rake::Task["sport_activities:import"].invoke

puts "🗂  Importing productivité activities from CSV..."
Rake::Task["productivite_activities:import"].invoke

puts "#{Activity.where(activity_type: "code_quiz", active: true).count} code quiz activities created"

puts "📸 Importing photo activities from CSV..."
Rake::Task["photo_activities:import"].invoke

if defined?(CultureQuestion)
  puts "🧠 Importing culture questions from CSV..."
  Rake::Task["culture_questions:import_csv"].invoke
end

if defined?(CodeQuestion)
  puts "💻 Importing code questions from CSV..."
  Rake::Task["code_questions:import_csv"].invoke
end

puts "✅ Seed completed!"

puts "#{User.count} users created"
puts "#{Interest.count} interests created"
puts "#{Location.count} locations created"
puts "#{Duration.count} durations created"
puts "#{Activity.count} activities created"
puts "#{LanguageItem.count} language items created"
puts "#{CultureQuestion.count} culture questions created" if defined?(CultureQuestion)

puts "#{Activity.where(interest: sport, active: true).count} active sport activities created"
puts "#{Activity.where(interest: languages, active: true).count} active language activities created"
puts "#{Activity.where(interest: culture, active: true).count} active culture activities created"

puts "#{Activity.where(activity_type: "word_learning", active: true).count} word learning activities created"
puts "#{Activity.where(activity_type: "sentence_completion", active: true).count} sentence completion activities created"
puts "#{Activity.where(activity_type: "llm_chat", active: false).count} inactive LLM chat activities created"
puts "#{Activity.where(activity_type: "culture_quiz", active: true).count} culture quiz activities created"

puts "Creating furnitures..."



Furniture.create!(
  name: "escalade",
  image_url: "furnitures/Escalade.png",
  interest: sport,
  required_xp: 50,
  width: 2,
  height: 1
)

Furniture.create!(
  name: "orangechair",
  image_url: "furnitures/chair.png",
  interest: productivite,
  required_xp: 5,
  width: 1,
  height: 1
)

Furniture.create!(
  name: "Punching Ball",
  image_url: "furnitures/punching_ball.png",
  width: 1,
  height: 1,
  interest: sport,
  required_xp: 30
)
Furniture.create!(
  name: "Pool",
  image_url: "furnitures/pool.png",
  width: 1,
  height: 1,
  interest: productivite,
  required_xp: 30
)

Furniture.create!(
  name: "Books",
  image_url: "furnitures/books.png",
  required_xp: 5,
  width: 1,
  height: 1,
  interest: culture
)

Furniture.create!(
  name: "Sport Mat",
  image_url: "furnitures/sport_mat.png",
  width: 2,
  height: 1,
  interest: sport,
  required_xp: 5
)

Furniture.create!(
  name: "Jasky",
  image_url: "furnitures/jasky.gif",
  width: 1,
  height: 1,
  interest: culture,
  required_xp: 30
)

puts "#{Furniture.count} furnitures created!"
