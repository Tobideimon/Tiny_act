module ApplicationHelper
  def mood_icon(name)
    case name.downcase
    when /forme|énergie|energie/
      "⚡"
    when /mitigé|mitige/
      "🌤️"
    when /plat|fatigué|fatigue/
      "🌧️"
    else
      "✨"
    end
  end

  def mood_subtitle(name)
    case name.downcase
    when /forme|énergie|energie/
      "J’ai de l’énergie !"
    when /mitigé|mitige/
      "Ça peut aller"
    when /plat|fatigué|fatigue/
      "Pas la grande forme"
    else
      "On va trouver une activité adaptée"
    end
  end
end

def mood_color_class(name)
  case name.downcase
  when /forme|énergie|energie/
    "mood-green"
  when /mitigé|mitige/
    "mood-yellow"
  when /plat|fatigué|fatigue/
    "mood-blue"
  else
    "mood-default"
  end
end
