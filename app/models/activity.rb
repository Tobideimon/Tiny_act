class Activity < ApplicationRecord
  belongs_to :duration
  belongs_to :interest
  belongs_to :location
  belongs_to :mood

  has_many :activity_sessions, dependent: :destroy

  validates :name, presence: true
  validates :content, presence: true

  scope :en_forme, -> {
    joins(:mood).where(moods: { name: "En forme" })
  }

  scope :mitige, -> {
    joins(:mood).where(moods: { name: "Mitigé" })
  }

  scope :a_plat, -> {
    joins(:mood).where(moods: { name: "À plat" })
  }

  scope :maison, -> {
    joins(:location).where(locations: { name: "Maison" })
  }

  scope :exterieur, -> {
    joins(:location).where(locations: { name: "Extérieur" })
  }

  scope :five_minutes, -> {
    joins(:duration).where(durations: { value: 5 })
  }

  scope :fifteen_minutes, -> {
    joins(:duration).where(durations: { value: 15 })
  }

  scope :thirty_minutes, -> {
    joins(:duration).where(durations: { value: 30 })
  }
end
