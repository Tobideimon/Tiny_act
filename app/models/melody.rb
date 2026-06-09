class Melody < ApplicationRecord
  DIFFICULTIES = %w[easy medium hard].freeze

  # Mêmes poids que le quiz code (CodeQuestion::WEIGHTS).
  # TODO (DRY) : une fois les deux features en place, on extraira ça dans un
  # module partagé pour avoir une seule source de vérité.
  DIFFICULTY_WEIGHTS_BY_MOOD = {
    "À plat"   => { "easy" => 0.70, "medium" => 0.25, "hard" => 0.05 },
    "Mitigé"   => { "easy" => 0.40, "medium" => 0.40, "hard" => 0.20 },
    "En forme" => { "easy" => 0.20, "medium" => 0.50, "hard" => 0.30 }
  }.freeze

  validates :name, presence: true, uniqueness: true
  validates :notes, presence: true
  validates :category, presence: true
  validates :difficulty, presence: true, inclusion: { in: DIFFICULTIES }

  scope :by_difficulty, ->(level) { where(difficulty: level) }
  scope :by_category,   ->(cat)   { where(category: cat) }

  # Tire UNE mélodie : difficulté pondérée par l'humeur, avec fallback robuste.
  # Important ici : on a peu de mélodies, et 0 en "hard" pour l'instant.
  def self.pick_for(mood_name)
    weights = DIFFICULTY_WEIGHTS_BY_MOOD.fetch(mood_name, DIFFICULTY_WEIGHTS_BY_MOOD["À plat"])
    level   = weighted_difficulty(weights)
    where(difficulty: level).order(Arel.sql("RANDOM()")).first ||
      order(Arel.sql("RANDOM()")).first   # fallback : n'importe quelle mélodie
  end

  # Choisit un niveau au hasard selon les poids (roulette).
  def self.weighted_difficulty(weights)
    roll = rand
    cumulative = 0.0
    weights.each do |level, weight|
      cumulative += weight
      return level if roll <= cumulative
    end
    weights.keys.last
  end
  private_class_method :weighted_difficulty
end
