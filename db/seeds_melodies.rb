puts "🎵 Importing melodies..."

melodies = [
  # --- Curated, domaine public vérifié ---
  { name: "Au clair de la lune", difficulty: "easy", category: "comptine", family: "folk_fr",
    notes: %w[C4 C4 C4 D4 E4 D4 C4 E4 D4 D4 C4],
    source: "Traditionnel français (18e s.), domaine public" },

  { name: "Ah vous dirai-je maman", difficulty: "medium", category: "comptine", family: "folk_fr",
    notes: %w[C4 C4 G4 G4 A4 A4 G4 F4 F4 E4 E4 D4 D4 C4],
    source: "Air anonyme publié en 1761, domaine public (Mozart n'en est pas le compositeur)" },

  { name: "Ode à la joie (thème)", difficulty: "medium", category: "classique", family: "beethoven",
    notes: %w[E4 E4 F4 G4 G4 F4 E4 D4 C4 C4 D4 E4 E4 D4 D4],
    source: "L. v. Beethoven (1824), domaine public (mort en 1827)" },

  # --- Exercices générés (exacts par construction, aucun droit) ---
  { name: "Gamme de Do majeur (montante)", difficulty: "easy", category: "exercice", family: "gamme",
    notes: %w[C4 D4 E4 F4 G4 A4 B4 C5], source: "Exercice généré" },

  { name: "Gamme de Do majeur (descendante)", difficulty: "easy", category: "exercice", family: "gamme",
    notes: %w[C5 B4 A4 G4 F4 E4 D4 C4], source: "Exercice généré" },

  { name: "Arpège de Do majeur", difficulty: "medium", category: "exercice", family: "arpege",
    notes: %w[C4 E4 G4 C5 G4 E4 C4], source: "Exercice généré" },

  { name: "Exercice de tierces", difficulty: "medium", category: "exercice", family: "tierces",
    notes: %w[C4 E4 D4 F4 E4 G4 F4 A4 G4 B4 A4 C5], source: "Exercice généré" }
]

melodies.each do |attrs|
  Melody.find_or_initialize_by(name: attrs[:name]).update!(attrs.except(:name))
end

puts "✅ #{Melody.count} mélodies en base | " \
     "#{Melody.where(difficulty: 'easy').count} easy / " \
     "#{Melody.where(difficulty: 'medium').count} medium / " \
     "#{Melody.where(difficulty: 'hard').count} hard"
