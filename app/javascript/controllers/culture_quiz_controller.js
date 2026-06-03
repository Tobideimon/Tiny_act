import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "card",
    "question",
    "answers",
    "progress",
    "feedback",
    "nextButton",
    "score"
  ]

  static values = {
    questions: Array
  }

  connect() {
    this.currentIndex = 0
    this.correctCount = 0
    this.answered = false

    this.showQuestion()
  }

  showQuestion() {
    const currentQuestion = this.questionsValue[this.currentIndex]

    this.answered = false

    this.cardTarget.classList.remove("quiz-card-correct", "quiz-card-wrong")
    this.questionTarget.textContent = currentQuestion.question
    this.feedbackTarget.textContent = ""
    this.feedbackTarget.classList.remove("is-correct", "is-wrong")

    this.progressTarget.textContent = `Question ${this.currentIndex + 1} / ${this.questionsValue.length}`

    this.answersTarget.innerHTML = ""

    currentQuestion.answers.forEach((answer) => {
      const button = document.createElement("button")

      button.type = "button"
      button.classList.add("quiz-answer")
      button.textContent = answer
      button.dataset.answer = answer
      button.dataset.action = "click->culture-quiz#selectAnswer"

      this.answersTarget.appendChild(button)
    })

    this.nextButtonTarget.classList.add("d-none")
  }

  selectAnswer(event) {
    if (this.answered) return

    this.answered = true

    const selectedButton = event.currentTarget
    const selectedAnswer = selectedButton.dataset.answer
    const currentQuestion = this.questionsValue[this.currentIndex]
    const correctAnswer = currentQuestion.correct_answer

    const answerButtons = this.answersTarget.querySelectorAll(".quiz-answer")

    answerButtons.forEach((button) => {
      button.disabled = true

      if (button.dataset.answer === correctAnswer) {
        button.classList.add("quiz-answer-correct")
      }
    })

    if (selectedAnswer === correctAnswer) {
      this.correctCount += 1

      this.cardTarget.classList.add("quiz-card-correct")
      selectedButton.classList.add("quiz-answer-correct")
      this.feedbackTarget.textContent = "Bonne réponse."
      this.feedbackTarget.classList.add("is-correct")
    } else {
      this.cardTarget.classList.add("quiz-card-wrong")
      selectedButton.classList.add("quiz-answer-wrong")
      this.feedbackTarget.textContent = `Mauvaise réponse. La bonne réponse était : ${correctAnswer}`
      this.feedbackTarget.classList.add("is-wrong")
    }

    if (this.currentIndex === this.questionsValue.length - 1) {
      this.nextButtonTarget.textContent = "Voir le résultat"
    } else {
      this.nextButtonTarget.textContent = "Question suivante"
    }

    this.nextButtonTarget.classList.remove("d-none")
  }

  nextQuestion() {
    if (!this.answered) return

    if (this.currentIndex === this.questionsValue.length - 1) {
      this.showResult()
      return
    }

    this.currentIndex += 1
    this.showQuestion()
  }

  showResult() {
    this.cardTarget.classList.remove("quiz-card-correct", "quiz-card-wrong")
    this.questionTarget.textContent = "Quiz terminé"
    this.answersTarget.innerHTML = ""
    this.feedbackTarget.textContent = ""
    this.nextButtonTarget.classList.add("d-none")

    this.progressTarget.textContent = "Résultat"

    this.scoreTarget.textContent = `${this.correctCount} bonne(s) réponse(s) sur ${this.questionsValue.length}.`
  }
}
