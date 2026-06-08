import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startScreen", "quizHeader", "card", "question", "answers",
                    "progress", "feedback", "nextButton", "score", "timer", "familyLabel"]
  static values = { questionsByFamily: Object, durationSeconds: Number, finishUrl: String }

  connect() {
    this.quizFinished = false
    this.startScreenTarget.hidden = false
    this.quizHeaderTarget.hidden = true
    this.cardTarget.hidden = true
    this.nextButtonTarget.hidden = true
  }

  chooseFamily(event) {
    const family = event.currentTarget.dataset.family
    const pool = this.questionsByFamilyValue[family] || []
    if (pool.length === 0) return
    this.activeFamily = family
    this.selectedQuestions = this.shuffle(pool)
    this.startQuiz()
  }

  startQuiz() {
    this.currentIndex = 0
    this.correctCount = 0
    this.completedCount = 0
    this.score = 0
    this.answered = false
    this.quizFinished = false
    this.remainingSeconds = this.durationSecondsValue || 300
    this.startScreenTarget.hidden = true
    this.quizHeaderTarget.hidden = false
    this.cardTarget.hidden = false
    this.nextButtonTarget.hidden = true
    if (this.hasFamilyLabelTarget) this.familyLabelTarget.textContent = this.activeFamily
    this.updateTimer()
    this.startTimer()
    this.showQuestion()
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
    this.nextButtonTarget.hidden = true
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
      this.score += this.pointsFor(q.difficulty)
      this.cardTarget.classList.add("quiz-card-correct")
      this.feedbackTarget.textContent = `Bonne réponse. +${this.pointsFor(q.difficulty)} pts`
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
    this.scoreTarget.textContent = this.completedCount === 0
      ? "Tu n'as pas encore répondu à une question."
      : `${this.score} points · ${this.correctCount} bonne(s) sur ${this.completedCount}.`
    this.nextButtonTarget.textContent = "Terminer"
    this.nextButtonTarget.dataset.action = "click->code-quiz#finishActivity"
    this.nextButtonTarget.hidden = false
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

  pointsFor(difficulty) { return { easy: 1, medium: 2, hard: 3 }[difficulty] || 1 }
  updateProgress() { if (this.hasProgressTarget) this.progressTarget.textContent = `${this.score} pts · ${this.correctCount}/${this.completedCount}` }
  shuffle(array) { return [...array].sort(() => Math.random() - 0.5) }
  csrfToken() { const t = document.querySelector("meta[name='csrf-token']"); return t ? t.content : "" }
}
