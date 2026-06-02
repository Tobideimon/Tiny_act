import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "timer",
    "nextButton",
    "wordPrompt",
    "wordAnswer",
    "sentencePrompt",
    "sentenceInput",
    "sentenceFeedback",
    "progress"
  ]

  static values = {
    items: Array,
    duration: Number,
    mode: String
  }

  connect() {
    this.currentIndex = 0
    this.completedCount = 0
    this.remainingSeconds = this.durationValue
    this.timerInterval = null

    this.updateTimer()

    if (this.modeValue === "word_learning") {
      this.showCurrentWord()
      this.startTimer()
    }

    if (this.modeValue === "sentence_completion") {
      this.showCurrentSentence()
      this.updateProgress()
      this.startTimer()

      if (this.hasSentenceInputTarget) {
        this.sentenceInputTarget.focus()
      }
    }
  }

  startTimer() {
    this.timerInterval = setInterval(() => {
      this.remainingSeconds -= 1
      this.updateTimer()

      if (this.remainingSeconds <= 0) {
        this.finish()
      }
    }, 1000)
  }

  nextWord() {
    if (this.remainingSeconds <= 0) return

    this.currentIndex = this.nextIndex()
    this.showCurrentWord()
  }

  checkSentence(event) {
    event.preventDefault()

    if (this.remainingSeconds <= 0) return

    const currentItem = this.itemsValue[this.currentIndex]
    const userAnswer = this.normalize(this.sentenceInputTarget.value)
    const expectedAnswer = this.normalize(currentItem.answer)

    if (userAnswer === expectedAnswer) {
      this.completedCount += 1
      this.updateProgress()

      this.sentenceFeedbackTarget.textContent = "Correct."
      this.sentenceFeedbackTarget.classList.remove("is-wrong")
      this.sentenceFeedbackTarget.classList.add("is-correct")

      setTimeout(() => {
        this.currentIndex = this.nextIndex()
        this.showCurrentSentence()
      }, 500)
    } else {
      this.sentenceFeedbackTarget.textContent = "Ce n’est pas le mot attendu. Réessaie."
      this.sentenceFeedbackTarget.classList.remove("is-correct")
      this.sentenceFeedbackTarget.classList.add("is-wrong")
    }
  }

  showCurrentWord() {
    const currentItem = this.itemsValue[this.currentIndex]

    this.wordPromptTarget.textContent = currentItem.prompt
    this.wordAnswerTarget.textContent = currentItem.answer

    this.completedCount += 1
    this.updateProgress()
  }

  showCurrentSentence() {
    const currentItem = this.itemsValue[this.currentIndex]

    this.sentencePromptTarget.textContent = currentItem.prompt
    this.sentenceInputTarget.value = ""
    this.sentenceFeedbackTarget.textContent = ""
    this.sentenceFeedbackTarget.classList.remove("is-correct", "is-wrong")

    this.sentenceInputTarget.focus()
  }

  nextIndex() {
    if (this.itemsValue.length === 0) return 0

    return (this.currentIndex + 1) % this.itemsValue.length
  }

  updateTimer() {
    const minutes = Math.floor(this.remainingSeconds / 60)
    const seconds = this.remainingSeconds % 60

    this.timerTarget.textContent = `${minutes}:${seconds.toString().padStart(2, "0")}`
  }

  updateProgress() {
    if (!this.hasProgressTarget) return

    if (this.modeValue === "word_learning") {
      const label = this.completedCount > 1 ? "mots faits" : "mot fait"
      this.progressTarget.textContent = `${this.completedCount} ${label}`
    }

    if (this.modeValue === "sentence_completion") {
      const label = this.completedCount > 1 ? "phrases faites" : "phrase faite"
      this.progressTarget.textContent = `${this.completedCount} ${label}`
    }
  }

  finish() {
    clearInterval(this.timerInterval)
    this.remainingSeconds = 0
    this.updateTimer()

    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = true
    }

    if (this.hasSentenceInputTarget) {
      this.sentenceInputTarget.disabled = true
    }

    if (this.hasSentenceFeedbackTarget) {
      this.sentenceFeedbackTarget.textContent = "Temps écoulé."
      this.sentenceFeedbackTarget.classList.remove("is-correct", "is-wrong")
    }
  }

  normalize(value) {
    return value
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
  }
}
