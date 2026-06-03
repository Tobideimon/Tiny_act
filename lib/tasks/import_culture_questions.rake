require "net/http"
require "json"
require "cgi"

namespace :culture_questions do
  desc "Import culture questions from Open Trivia DB"
  task import: :environment do
    targets = {
      "easy" => ENV.fetch("EASY", 350).to_i,
      "medium" => ENV.fetch("MEDIUM", 350).to_i,
      "hard" => ENV.fetch("HARD", 300).to_i
    }

    puts "🌍 Requesting Open Trivia DB token..."

    token_uri = URI("https://opentdb.com/api_token.php?command=request")
    token_response = JSON.parse(Net::HTTP.get(token_uri))
    token = token_response["token"]

    raise "Could not retrieve Open Trivia DB token" if token.blank?

    targets.each do |difficulty, target_count|
      imported_for_difficulty = 0

      puts "🧠 Importing #{target_count} #{difficulty} questions..."

      while imported_for_difficulty < target_count
        amount = [50, target_count - imported_for_difficulty].min

        uri = URI("https://opentdb.com/api.php")
        uri.query = URI.encode_www_form(
          amount: amount,
          difficulty: difficulty,
          type: "multiple",
          token: token
        )

        response = JSON.parse(Net::HTTP.get(uri))

        case response["response_code"]
        when 0
          response["results"].each do |item|
            question_text = CGI.unescapeHTML(item["question"].to_s.strip)
            correct_answer = CGI.unescapeHTML(item["correct_answer"].to_s.strip)

            incorrect_answers = item["incorrect_answers"].map do |answer|
              CGI.unescapeHTML(answer.to_s.strip)
            end

            next unless incorrect_answers.size == 3
            next if CultureQuestion.exists?(question: question_text)

            CultureQuestion.create!(
              question: question_text,
              correct_answer: correct_answer,
              wrong_answer_1: incorrect_answers[0],
              wrong_answer_2: incorrect_answers[1],
              wrong_answer_3: incorrect_answers[2],
              category: item["category"],
              difficulty: item["difficulty"],
              source: "Open Trivia DB"
            )

            imported_for_difficulty += 1
          end

          puts "#{difficulty}: #{imported_for_difficulty} / #{target_count}"

        when 1
          puts "No more results for difficulty #{difficulty}."
          break
        when 4
          puts "Token empty. Stopping import for #{difficulty}."
          break
        when 5
          puts "Rate limit reached. Waiting..."
        else
          raise "Open Trivia DB error code: #{response['response_code']}"
        end

        sleep 5.2 if imported_for_difficulty < target_count
      end
    end

    puts "✅ Culture questions import completed!"
    puts "#{CultureQuestion.count} total culture questions"
    puts "#{CultureQuestion.where(difficulty: 'easy').count} easy"
    puts "#{CultureQuestion.where(difficulty: 'medium').count} medium"
    puts "#{CultureQuestion.where(difficulty: 'hard').count} hard"
  end
end
