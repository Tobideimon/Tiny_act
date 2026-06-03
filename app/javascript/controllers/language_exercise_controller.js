import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "timer",
    "progress",
    "prompt",
    "answer",
    "sentenceForm",
    "sentenceInput",
    "feedback",
    "wordPanel",
    "sentencePanel",
    "finishedPanel",
    "score"
  ]

  static values = {
    items: Array,
    duration: Number,
    activityType: String
  }

  connect() {
    this.items = [...this.itemsValue]
    this.currentIndex = 0
    this.correctAnswers = 0
    this.seenItems = 0
    this.totalSeconds = this.durationValue * 60
    this.remainingSeconds = this.totalSeconds

    if (this.items.length === 0) {
      this.finish("Aucun contenu disponible pour cet exercice.")
      return
    }

    this.renderCurrentItem()
    this.updateTimer()

    this.interval = setInterval(() => {
      this.remainingSeconds -= 1
      this.updateTimer()

      if (this.remainingSeconds <= 0) {
        this.finish("Temps écoulé.")
      }
    }, 1000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  nextWord() {
    this.seenItems += 1
    this.currentIndex += 1
    this.renderCurrentItem()
  }

  checkAnswer(event) {
    event.preventDefault()

    const item = this.currentItem()
    const userAnswer = this.normalize(this.sentenceInputTarget.value)
    const expectedAnswer = this.normalize(item.answer)

    if (userAnswer === expectedAnswer) {
      this.correctAnswers += 1
      this.seenItems += 1
      this.feedbackTarget.textContent = "Correct."
      this.feedbackTarget.classList.remove("is-wrong")
      this.feedbackTarget.classList.add("is-correct")

      setTimeout(() => {
        this.currentIndex += 1
        this.sentenceInputTarget.value = ""
        this.feedbackTarget.textContent = ""
        this.feedbackTarget.classList.remove("is-correct")
        this.renderCurrentItem()
      }, 400)
    } else {
      this.feedbackTarget.textContent = "Ce n’est pas encore ça. Réessaie."
      this.feedbackTarget.classList.remove("is-correct")
      this.feedbackTarget.classList.add("is-wrong")
    }
  }

  renderCurrentItem() {
    if (this.remainingSeconds <= 0) return

    if (this.currentIndex >= this.items.length) {
      this.shuffleItems()
      this.currentIndex = 0
    }

    const item = this.currentItem()

    this.progressTarget.textContent = `${this.seenItems + 1}`

    if (this.activityTypeValue === "word_learning") {
      this.wordPanelTarget.hidden = false
      this.sentencePanelTarget.hidden = true

      this.promptTarget.textContent = item.prompt
      this.answerTarget.textContent = item.answer
    }

    if (this.activityTypeValue === "sentence_completion") {
      this.wordPanelTarget.hidden = true
      this.sentencePanelTarget.hidden = false

      this.promptTarget.textContent = item.prompt
      this.sentenceInputTarget.focus()
    }
  }

  currentItem() {
    return this.items[this.currentIndex]
  }

  updateTimer() {
    const minutes = Math.floor(this.remainingSeconds / 60)
    const seconds = this.remainingSeconds % 60

    this.timerTarget.textContent = `${minutes}:${seconds.toString().padStart(2, "0")}`
  }

  finish(message) {
    if (this.interval) clearInterval(this.interval)

    this.wordPanelTarget.hidden = true
    this.sentencePanelTarget.hidden = true
    this.finishedPanelTarget.hidden = false

    this.feedbackTarget.textContent = message

    if (this.activityTypeValue === "sentence_completion") {
      this.scoreTarget.textContent = `${this.correctAnswers} bonne(s) réponse(s)`
    } else {
      this.scoreTarget.textContent = `${this.seenItems} mot(s) vu(s)`
    }
  }

  shuffleItems() {
    this.items = this.items
      .map((item) => ({ item, sort: Math.random() }))
      .sort((a, b) => a.sort - b.sort)
      .map(({ item }) => item)
  }

  normalize(value) {
    return value
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
  }
}
