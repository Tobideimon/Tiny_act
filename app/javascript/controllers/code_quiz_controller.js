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
    "launchButton"
  ]

  static values = {
    questions: Array,
    durationSeconds: Number,
    finishUrl: String
  }

  connect() {
    this.currentIndex = 0
    this.correctCount = 0
    this.completedCount = 0
    this.score = 0
    this.answered = false
    this.selectedQuestions = []
    this.remainingSeconds = this.durationSecondsValue || 300
    this.timerInterval = null
    this.quizFinished = false
    this.startScreenTarget.hidden = false
    this.quizHeaderTarget.hidden = true
    this.cardTarget.hidden = true
    this.nextButtonTarget.hidden = true
    this.nextButtonTarget.disabled = true

    this.dispatchControlsChanged()
  }

  disconnect() {
    this.clearTimer()
  }

  chooseFamily(event) {
    const family = event.currentTarget.dataset.family
    const pool = this.questionsByFamilyValue[family] || []
    if (pool.length === 0) return
    this.activeFamily = family
    this.selectedQuestions = this.shuffle(pool)
    this.startQuiz()
  }

    this.currentIndex = 0
    this.correctCount = 0
    this.completedCount = 0
    this.score = 0
    this.answered = false
    this.quizFinished = false
    this.remainingSeconds = this.durationSecondsValue || 300
    this.selectedQuestions = this.shuffle(this.questionsValue)

    this.startScreenTarget.hidden = true
    this.quizHeaderTarget.hidden = false
    this.cardTarget.hidden = false
    this.nextButtonTarget.hidden = true
    this.nextButtonTarget.disabled = true

    this.updateTimer()
    this.startTimer()
    this.showQuestion()
    this.dispatchControlsChanged()
  }

  startTimer() {
    this.clearTimer()
    this.timerInterval = setInterval(() => {
      this.remainingSeconds -= 1
      this.updateTimer()
      if (this.remainingSeconds <= 0) { this.clearTimer(); this.showResult() }
    }, 1000)
  }

  clearTimer() { if (this.timerInterval) { clearInterval(this.timerInterval); this.timerInterval = null } }

  updateTimer() {
    if (!this.hasTimerTarget) return
    const s = Math.max(0, this.remainingSeconds)
    this.timerTarget.textContent = `${Math.floor(s / 60)}:${(s % 60).toString().padStart(2, "0")}`
  }

  showQuestion() {
    if (this.quizFinished) return
    if (this.remainingSeconds <= 0) return this.showResult()
    if (this.currentIndex >= this.selectedQuestions.length) {
      this.selectedQuestions = this.shuffle(this.questionsByFamilyValue[this.activeFamily])
      this.currentIndex = 0
    }
    const q = this.selectedQuestions[this.currentIndex]
    if (!q) return this.showResult()

    this.answered = false
    this.cardTarget.classList.remove("quiz-card-correct", "quiz-card-wrong")
    this.questionTarget.textContent = q.question
    this.feedbackTarget.textContent = ""
    this.scoreTarget.textContent = ""
    this.feedbackTarget.classList.remove("is-correct", "is-wrong")
    this.updateProgress()
    this.answersTarget.innerHTML = ""
    this.shuffle(q.answers).forEach((answer) => {
      const b = document.createElement("button")
      b.type = "button"
      b.classList.add("quiz-answer")
      b.textContent = answer
      b.dataset.answer = answer
      b.dataset.action = "click->code-quiz#selectAnswer"
      this.answersTarget.appendChild(b)
    })

    this.nextButtonTarget.textContent = "Question suivante"
    this.nextButtonTarget.hidden = true
    this.nextButtonTarget.disabled = true

    this.dispatchControlsChanged()
  }

  selectAnswer(event) {
    if (this.answered || this.quizFinished) return
    if (this.remainingSeconds <= 0) return this.showResult()
    this.answered = true
    this.completedCount += 1
    const selected = event.currentTarget
    const q = this.selectedQuestions[this.currentIndex]
    const correct = q.correct_answer

    this.answersTarget.querySelectorAll(".quiz-answer").forEach((b) => {
      b.disabled = true
      if (b.dataset.answer === correct) b.classList.add("quiz-answer-correct")
    })

    if (selected.dataset.answer === correct) {
      this.correctCount += 1
      this.score += this.pointsFor(currentQuestion.difficulty)

      this.cardTarget.classList.add("quiz-card-correct")
      selectedButton.classList.add("quiz-answer-correct")
      this.feedbackTarget.textContent = `Bonne réponse. +${this.pointsFor(currentQuestion.difficulty)} pts`
      this.feedbackTarget.classList.add("is-correct")
    } else {
      this.cardTarget.classList.add("quiz-card-wrong")
      selected.classList.add("quiz-answer-wrong")
      this.feedbackTarget.textContent = `Mauvaise réponse. La bonne réponse était : ${correct}`
      this.feedbackTarget.classList.add("is-wrong")
    }

    this.updateProgress()
    this.nextButtonTarget.textContent = "Question suivante"
    this.nextButtonTarget.dataset.action = "click->code-quiz#nextQuestion"
    this.nextButtonTarget.hidden = false
    this.nextButtonTarget.disabled = false

    this.dispatchControlsChanged()
  }

  nextQuestion() {
    if (!this.answered || this.quizFinished) return
    if (this.remainingSeconds <= 0) return this.showResult()
    this.currentIndex += 1
    this.showQuestion()
  }

  showResult() {
    if (this.quizFinished) return
    this.quizFinished = true
    this.clearTimer()
    this.updateTimer()
    this.cardTarget.hidden = false
    this.cardTarget.classList.remove("quiz-card-correct", "quiz-card-wrong")
    this.questionTarget.textContent = "Temps écoulé"
    this.answersTarget.innerHTML = ""
    this.feedbackTarget.textContent = ""

    this.progressTarget.textContent = `${this.score} pts`

    if (this.completedCount === 0) {
      this.scoreTarget.textContent = "Tu n’as pas encore répondu à une question."
    } else {
      this.scoreTarget.textContent = `${this.score} points · ${this.correctCount} bonne(s) sur ${this.completedCount}.`
    }

    this.nextButtonTarget.hidden = true
    this.nextButtonTarget.disabled = true

    this.element.dispatchEvent(
      new CustomEvent("activity:finished", {
        bubbles: true
      })
    )
  }

  finishActivity() {
    if (!this.hasFinishUrlValue) return
    this.nextButtonTarget.disabled = true
    this.nextButtonTarget.textContent = "Validation..."
    const form = document.createElement("form")
    form.method = "post"
    form.action = this.finishUrlValue
    form.style.display = "none"
    form.insertAdjacentHTML("beforeend",
      `<input type="hidden" name="_method" value="patch">
       <input type="hidden" name="authenticity_token" value="${this.csrfToken()}">`)
    document.body.appendChild(form)
    form.submit()
  }

  pointsFor(difficulty) {
    return {
      easy: 1,
      medium: 2,
      hard: 3
    }[difficulty] || 1
  }

  updateProgress() {
    if (!this.hasProgressTarget) return

    this.progressTarget.textContent = `${this.score} pts · ${this.correctCount}/${this.completedCount}`
  }

  dispatchControlsChanged() {
    this.element.dispatchEvent(
      new CustomEvent("activity:controls-changed", {
        bubbles: true
      })
    )
  }

  shuffle(array) {
    return [...array].sort(() => Math.random() - 0.5)
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }
}
