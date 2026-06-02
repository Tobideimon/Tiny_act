class AddLanguageToActivitySessions < ActiveRecord::Migration[8.1]
  def change
    add_column :activity_sessions, :language, :string
  end
end
