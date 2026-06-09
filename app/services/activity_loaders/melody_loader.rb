module ActivityLoaders
  class MelodyLoader < BaseLoader
    def call
      super.merge(
        melody: melody_data
      )
    end

    private

    def melody_data
      melody = Melody.pick_for(activity.mood.name)
      return nil if melody.nil?

      {
        name: melody.name,
        notes: melody.notes,
        difficulty: melody.difficulty,
        category: melody.category,
        source: melody.source
      }
    end
  end
end
