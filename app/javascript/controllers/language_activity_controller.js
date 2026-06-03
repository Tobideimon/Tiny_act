import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "timer",
    "nextButton",
    "revealTranslationButton",
    "wordPrompt",
    "wordAnswer",
    "sentenceTranslation",
    "sentenceBefore",
    "sentenceAfter",
    "sentenceInput",
    "revealedAnswer",
    "sentenceFeedback",
    "submitButton",
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
    this.sentenceAttempts = 0

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

  toggleWordTranslation() {
    if (!this.hasWordAnswerTarget) return

    const isHidden = this.wordAnswerTarget.classList.contains("is-hidden")

    if (isHidden) {
      this.wordAnswerTarget.classList.remove("is-hidden")
      this.revealTranslationButtonTarget.textContent = "Masquer la traduction"
    } else {
      this.wordAnswerTarget.classList.add("is-hidden")
      this.revealTranslationButtonTarget.textContent = "Voir la traduction"
    }
  }

  checkSentence(event) {
    event.preventDefault()

    if (this.remainingSeconds <= 0) return

    const currentItem = this.itemsValue[this.currentIndex]
    const userAnswer = this.normalize(this.sentenceInputTarget.value)
    const expectedAnswer = this.normalize(currentItem.answer)

    this.clearSentenceState()

    if (userAnswer === expectedAnswer) {
      this.completedCount += 1
      this.updateProgress()

      this.sentenceInputTarget.classList.add("is-correct")
      this.submitButtonTarget.classList.add("is-correct")
      this.sentenceFeedbackTarget.textContent = "Correct."
      this.sentenceFeedbackTarget.classList.add("is-correct")

      setTimeout(() => {
        this.currentIndex = this.nextIndex()
        this.showCurrentSentence()
      }, 800)

      return
    }

    this.sentenceAttempts += 1

    if (this.sentenceAttempts >= 3) {
      this.revealSentenceAnswer(currentItem)
      return
    }

    this.sentenceInputTarget.value = ""
    this.sentenceInputTarget.classList.add("is-wrong")
    this.submitButtonTarget.classList.add("is-wrong")
    this.sentenceFeedbackTarget.textContent = "Ce n’est pas le mot attendu. Réessaie."
    this.sentenceFeedbackTarget.classList.add("is-wrong")
    this.sentenceInputTarget.focus()
  }

  showCurrentWord() {
    const currentItem = this.itemsValue[this.currentIndex]

    this.wordPromptTarget.textContent = currentItem.prompt
    this.wordAnswerTarget.textContent = currentItem.translation || currentItem.answer
    this.wordAnswerTarget.classList.add("is-hidden")

    if (this.hasRevealTranslationButtonTarget) {
      this.revealTranslationButtonTarget.textContent = "Voir la traduction"
    }

    this.completedCount += 1
    this.updateProgress()
  }

  showCurrentSentence() {
    const currentItem = this.itemsValue[this.currentIndex]
    const sentenceParts = this.splitSentence(currentItem.prompt)

    this.sentenceAttempts = 0

    this.sentenceTranslationTarget.textContent = currentItem.translation
    this.sentenceBeforeTarget.textContent = sentenceParts.before
    this.sentenceAfterTarget.textContent = sentenceParts.after

    this.sentenceInputTarget.value = ""
    this.sentenceInputTarget.disabled = false
    this.sentenceInputTarget.classList.remove("is-hidden")
    this.sentenceInputTarget.placeholder = this.blankFor(currentItem.answer)
    this.sentenceInputTarget.style.width = `${Math.max(currentItem.answer.length + 1, 4)}ch`

    this.revealedAnswerTarget.textContent = ""
    this.revealedAnswerTarget.classList.add("is-hidden")

    this.submitButtonTarget.disabled = false

    this.clearSentenceState()
    this.sentenceFeedbackTarget.textContent = ""

    this.sentenceInputTarget.focus()
  }

  revealSentenceAnswer(currentItem) {
    this.sentenceInputTarget.value = ""
    this.sentenceInputTarget.disabled = true
    this.sentenceInputTarget.classList.add("is-hidden")

    this.revealedAnswerTarget.textContent = currentItem.answer
    this.revealedAnswerTarget.classList.remove("is-hidden")
    this.revealedAnswerTarget.classList.add("is-wrong")

    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.classList.add("is-wrong")

    this.sentenceFeedbackTarget.textContent = "La réponse était affichée. On passe à la suivante."
    this.sentenceFeedbackTarget.classList.add("is-wrong")

    setTimeout(() => {
      this.currentIndex = this.nextIndex()
      this.showCurrentSentence()
    }, 1800)
  }

  splitSentence(sentence) {
    const placeholder = sentence.match(/_{2,}/)

    if (!placeholder) {
      return {
        before: sentence,
        after: ""
      }
    }

    const startIndex = placeholder.index
    const endIndex = startIndex + placeholder[0].length

    return {
      before: sentence.slice(0, startIndex),
      after: sentence.slice(endIndex)
    }
  }

  blankFor(answer) {
    return answer
      .split(" ")
      .map((word) => "_".repeat(Math.max(word.length, 3)))
      .join(" ")
  }

  clearSentenceState() {
    if (this.hasSentenceInputTarget) {
      this.sentenceInputTarget.classList.remove("is-correct", "is-wrong")
    }

    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.classList.remove("is-correct", "is-wrong")
    }

    if (this.hasSentenceFeedbackTarget) {
      this.sentenceFeedbackTarget.classList.remove("is-correct", "is-wrong")
    }

    if (this.hasRevealedAnswerTarget) {
      this.revealedAnswerTarget.classList.remove("is-wrong")
    }
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
      const label = this.completedCount > 1 ? "mots vus" : "mot vu"
      this.progressTarget.textContent = `${this.completedCount} ${label}`
    }

    if (this.modeValue === "sentence_completion") {
      const label = this.completedCount > 1 ? "phrases réussies" : "phrase réussie"
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

    if (this.hasRevealTranslationButtonTarget) {
      this.revealTranslationButtonTarget.disabled = true
    }

    if (this.hasSentenceInputTarget) {
      this.sentenceInputTarget.disabled = true
    }

    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
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
