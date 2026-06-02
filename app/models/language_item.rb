class LanguageItem < ApplicationRecord
  ITEM_TYPES = %w[word sentence]
  LANGUAGES = %w[english spanish]

  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :prompt, presence: true
  validates :answer, presence: true
  validates :language, presence: true, inclusion: { in: LANGUAGES }
end
