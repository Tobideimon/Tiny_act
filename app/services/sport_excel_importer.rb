require "roo"

class SportExcelImporter

  FILE_PATH =
    Rails.root.join(
      "db",
      "data",
      "tiny_act_sport_base.xlsx"
    )

  def call

    sheet =
      Roo::Excelx.new(FILE_PATH)

    sport_interest =
      Interest.find_by!(name: "Sport")

    (2..sheet.last_row).each do |row|

      name =
        sheet.cell(row, 1)

      content =
        sheet.cell(row, 2)

      mood_name =
        sheet.cell(row, 3)

      location_name =
        sheet.cell(row, 4)

      duration_value =
        sheet.cell(row, 5)

      Activity.find_or_create_by!(
        name: name
      ) do |activity|

        activity.content = content

        activity.interest =
          sport_interest

        activity.mood =
          Mood.find_by!(
            name: mood_name
          )

        activity.location =
          Location.find_by!(
            name: location_name
          )

        activity.duration =
          Duration.find_by!(
            value: duration_value
          )

        activity.activity_type = "standard"
      end
    end
  end
end
