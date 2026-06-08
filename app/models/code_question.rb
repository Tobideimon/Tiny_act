class CodeQuestion < ApplicationRecord
  validates :question, presence: true, uniqueness: true
  validates :correct_answer, :wrong_answer_1, :wrong_answer_2, :wrong_answer_3,
            :category, :difficulty, presence: true

  FAMILIES = {
    "Ruby" => "Ruby / Rails", "Rails" => "Ruby / Rails",
    "HTML" => "Front (HTML / CSS / JS)", "CSS" => "Front (HTML / CSS / JS)", "JavaScript" => "Front (HTML / CSS / JS)",
    "SQL" => "Données & Outils", "Git" => "Données & Outils", "API" => "Données & Outils",
    "IA"  => "IA"
  }.freeze
  FAMILY_NAMES = FAMILIES.values.uniq.freeze

  WEIGHTS = {
    "À plat"   => { "easy" => 0.70, "medium" => 0.25, "hard" => 0.05 },
    "Mitigé"   => { "easy" => 0.40, "medium" => 0.40, "hard" => 0.20 },
    "En forme" => { "easy" => 0.20, "medium" => 0.50, "hard" => 0.30 }
  }.freeze

  # Tire un pool selon le mix de difficulté du mood, avec fallback si un niveau manque.
  def self.weighted_pool(family:, mood_name:, limit:)
    weights = WEIGHTS.fetch(mood_name, WEIGHTS["À plat"])
    pool = []

    weights.each do |level, weight|
      want = (limit * weight).round
      next if want <= 0
      pool.concat(where(family: family, difficulty: level)
                    .order(Arel.sql("RANDOM()")).limit(want).to_a)
    end

    if pool.size < limit # complète si un niveau était trop pauvre (ex. hard en IA/HTML)
      pool.concat(where(family: family).where.not(id: pool.map(&:id))
                    .order(Arel.sql("RANDOM()")).limit(limit - pool.size).to_a)
    end

    pool.shuffle
  end

  def answers
    [correct_answer, wrong_answer_1, wrong_answer_2, wrong_answer_3].shuffle
  end
end
