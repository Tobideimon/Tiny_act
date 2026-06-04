import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startScreen",
    "quizHeader",
    "card",
    "question",
    "answers",
    "progress",
    "feedback",
    "nextButton",
    "score",
    "timer",
    "selectedCategory"
  ]

  static values = {
    questions: Array,
    durationSeconds: Number
  }

  connect() {
    this.currentIndex = 0
    this.correctCount = 0
    this.answered = false
    this.selectedQuestions = []
    this.remainingSeconds = this.durationSecondsValue || 300
    this.timerInterval = null

    this.updateTimerDisplay()
  }

  selectCategory(event) {
    const category = event.currentTarget.dataset.category

    this.selectedQuestions = this.questionsValue.filter((question) => {
      return question.category === category
    })

    if (this.selectedQuestions.length === 0) return

    this.currentIndex = 0
    this.correctCount = 0
    this.answered = false
    this.remainingSeconds = this.durationSecondsValue || 300

    this.selectedCategoryTarget.textContent = category

    this.startScreenTarget.classList.add("d-none")
    this.quizHeaderTarget.classList.remove("d-none")
    this.cardTarget.classList.remove("d-none")

    this.startTimer()
    this.showQuestion()
  }

  showQuestion() {
    const currentQuestion = this.selectedQuestions[this.currentIndex]

    if (!currentQuestion) {
      this.showResult("Quiz terminé")
      return
    }

    this.answered = false

    this.cardTarget.classList.remove("quiz-card-correct", "quiz-card-wrong")
    this.questionTarget.textContent = currentQuestion.question
    this.feedbackTarget.textContent = ""
    this.scoreTarget.textContent = ""
    this.feedbackTarget.classList.remove("is-correct", "is-wrong")

    this.progressTarget.textContent = `Question ${this.currentIndex + 1} / ${this.selectedQuestions.length}`

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
    const currentQuestion = this.selectedQuestions[this.currentIndex]
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

    if (this.currentIndex === this.selectedQuestions.length - 1) {
      this.nextButtonTarget.textContent = "Voir le résultat"
    } else {
      this.nextButtonTarget.textContent = "Question suivante"
    }

    this.nextButtonTarget.classList.remove("d-none")
  }

  nextQuestion() {
    if (!this.answered) return

    if (this.currentIndex === this.selectedQuestions.length - 1) {
      this.showResult("Quiz terminé")
      return
    }

    this.currentIndex += 1
    this.showQuestion()
  }

  startTimer() {
    this.clearTimer()
    this.updateTimerDisplay()

    this.timerInterval = setInterval(() => {
      this.remainingSeconds -= 1
      this.updateTimerDisplay()

      if (this.remainingSeconds <= 0) {
        this.showResult("Temps écoulé")
      }
    }, 1000)
  }

  clearTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  updateTimerDisplay() {
    const safeSeconds = Math.max(0, Number(this.remainingSeconds || 0))
    const minutes = Math.floor(safeSeconds / 60)
    const seconds = safeSeconds % 60

    this.timerTarget.textContent = `${minutes}:${seconds.toString().padStart(2, "0")}`
  }

  showResult(title) {
    this.clearTimer()

    this.cardTarget.classList.remove("quiz-card-correct", "quiz-card-wrong")
    this.questionTarget.textContent = title
    this.answersTarget.innerHTML = ""
    this.feedbackTarget.textContent = ""
    this.nextButtonTarget.classList.add("d-none")

    this.progressTarget.textContent = "Résultat"

    this.scoreTarget.textContent = `${this.correctCount} bonne(s) réponse(s) sur ${this.currentIndex + (this.answered ? 1 : 0)} question(s) jouée(s).`
  }
}
