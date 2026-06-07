import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startScreen",
    "statusPanel",
    "wordCard",
    "sentenceCard",
    "resultCard",
    "launchButton",
    "nextButton",
    "finishButton",
    "revealTranslationButton",
    "wordPrompt",
    "wordAnswer",
    "sentenceForm",
    "sentenceTranslation",
    "sentenceBefore",
    "sentenceAfter",
    "sentenceInput",
    "revealedAnswer",
    "sentenceFeedback",
    "submitButton",
    "progress",
    "timer",
    "resultText"
  ]

  static values = {
    items: Array,
    mode: String,
    durationSeconds: Number,
    finishUrl: String
  }

  connect() {
    this.currentIndex = 0
    this.completedCount = 0
    this.correctCount = 0
    this.sentenceAttempts = 0
    this.waitingForSentenceNext = false
    this.remainingSeconds = this.durationSecondsValue || 300
    this.timerInterval = null
    this.activityFinished = false
    this.selectedItems = this.shuffle(this.itemsValue)

    this.showStartScreen()
  }

  showStartScreen() {
    if (this.hasStartScreenTarget) this.startScreenTarget.hidden = false
    if (this.hasStatusPanelTarget) this.statusPanelTarget.hidden = true
    if (this.hasWordCardTarget) this.wordCardTarget.hidden = true
    if (this.hasSentenceCardTarget) this.sentenceCardTarget.hidden = true
    if (this.hasResultCardTarget) this.resultCardTarget.hidden = true
    if (this.hasNextButtonTarget) this.nextButtonTarget.hidden = true
  }

  launch() {
    if (this.itemsValue.length === 0) return

    this.currentIndex = 0
    this.completedCount = 0
    this.correctCount = 0
    this.sentenceAttempts = 0
    this.waitingForSentenceNext = false
    this.remainingSeconds = this.durationSecondsValue || 300
    this.activityFinished = false
    this.selectedItems = this.shuffle(this.itemsValue)

    this.startScreenTarget.hidden = true
    this.statusPanelTarget.hidden = false

    if (this.modeValue === "word_learning") {
      this.wordCardTarget.hidden = false
      this.nextButtonTarget.hidden = false
      this.nextButtonTarget.textContent = "Mot suivant"
      this.showCurrentWord()
    }

    if (this.modeValue === "sentence_completion") {
      this.sentenceCardTarget.hidden = false
      this.showCurrentSentence()
    }

    this.updateTimer()
    this.updateProgress()
    this.startTimer()
  }

  startTimer() {
    this.clearTimer()

    this.timerInterval = setInterval(() => {
      this.remainingSeconds -= 1
      this.updateTimer()

      if (this.remainingSeconds <= 0) {
        this.clearTimer()
        this.showResult()
      }
    }, 1000)
  }

  clearTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  updateTimer() {
    if (!this.hasTimerTarget) return

    const safeSeconds = Math.max(0, this.remainingSeconds)
    const minutes = Math.floor(safeSeconds / 60)
    const seconds = safeSeconds % 60

    this.timerTarget.textContent = `${minutes}:${seconds.toString().padStart(2, "0")}`
  }

  nextWord() {
    if (this.activityFinished) return

    if (this.remainingSeconds <= 0) {
      this.showResult()
      return
    }

    this.currentIndex += 1
    this.showCurrentWord()
  }

  showCurrentWord() {
    if (this.activityFinished) return

    if (this.remainingSeconds <= 0) {
      this.showResult()
      return
    }

    if (this.currentIndex >= this.selectedItems.length) {
      this.selectedItems = this.shuffle(this.itemsValue)
      this.currentIndex = 0
    }

    const currentItem = this.selectedItems[this.currentIndex]

    if (!currentItem) {
      this.showResult()
      return
    }

    this.completedCount += 1

    this.wordPromptTarget.textContent = currentItem.prompt
    this.wordAnswerTarget.textContent = currentItem.translation || currentItem.answer
    this.wordAnswerTarget.classList.add("is-hidden")

    if (this.hasRevealTranslationButtonTarget) {
      this.revealTranslationButtonTarget.textContent = "Voir la traduction"
    }

    this.updateProgress()
  }

  toggleWordTranslation() {
    if (!this.hasWordAnswerTarget || this.activityFinished) return

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

    if (this.activityFinished) return

    if (this.remainingSeconds <= 0) {
      this.showResult()
      return
    }

    if (this.waitingForSentenceNext) {
      this.goToNextSentence()
      return
    }

    const currentItem = this.selectedItems[this.currentIndex]
    const userAnswer = this.normalize(this.sentenceInputTarget.value)
    const expectedAnswer = this.normalize(currentItem.answer)

    this.clearSentenceState()

    if (userAnswer === expectedAnswer) {
      this.completedCount += 1
      this.correctCount += 1
      this.updateProgress()

      this.sentenceInputTarget.classList.add("is-correct")
      this.submitButtonTarget.classList.add("is-correct")
      this.sentenceFeedbackTarget.textContent = "Correct."
      this.sentenceFeedbackTarget.classList.add("is-correct")

      this.lockSentenceBeforeNext()
      this.submitButtonTarget.textContent = "Phrase suivante"

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

  goToNextSentence() {
    this.currentIndex += 1
    this.showCurrentSentence()
  }

  showCurrentSentence() {
    if (this.activityFinished) return

    if (this.remainingSeconds <= 0) {
      this.showResult()
      return
    }

    if (this.currentIndex >= this.selectedItems.length) {
      this.selectedItems = this.shuffle(this.itemsValue)
      this.currentIndex = 0
    }

    const currentItem = this.selectedItems[this.currentIndex]

    if (!currentItem) {
      this.showResult()
      return
    }

    const sentenceParts = this.splitSentence(currentItem.prompt)

    this.sentenceAttempts = 0
    this.waitingForSentenceNext = false

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
    this.submitButtonTarget.textContent = "Valider"

    this.clearSentenceState()
    this.sentenceFeedbackTarget.textContent = ""

    this.sentenceInputTarget.focus()
    this.updateProgress()
  }

  revealSentenceAnswer(currentItem) {
    this.completedCount += 1
    this.updateProgress()

    this.sentenceInputTarget.value = ""
    this.sentenceInputTarget.disabled = true
    this.sentenceInputTarget.classList.add("is-hidden")

    this.revealedAnswerTarget.textContent = currentItem.answer
    this.revealedAnswerTarget.classList.remove("is-hidden")
    this.revealedAnswerTarget.classList.add("is-wrong")

    this.submitButtonTarget.classList.add("is-wrong")

    this.sentenceFeedbackTarget.textContent = "La réponse était affichée."
    this.sentenceFeedbackTarget.classList.add("is-wrong")

    this.lockSentenceBeforeNext()
    this.submitButtonTarget.textContent = "Phrase suivante"
  }

  lockSentenceBeforeNext() {
    this.waitingForSentenceNext = true

    if (this.hasSentenceInputTarget) {
      this.sentenceInputTarget.disabled = true
    }
  }

  showResult() {
    if (this.activityFinished) return

    this.activityFinished = true
    this.clearTimer()
    this.updateTimer()

    if (this.hasWordCardTarget) this.wordCardTarget.hidden = true
    if (this.hasSentenceCardTarget) this.sentenceCardTarget.hidden = true
    if (this.hasNextButtonTarget) this.nextButtonTarget.hidden = true

    this.resultCardTarget.hidden = false

    if (this.modeValue === "word_learning") {
      this.resultTextTarget.textContent = `${this.completedCount} mot(s) vus pendant la session.`
    }

    if (this.modeValue === "sentence_completion") {
      this.resultTextTarget.textContent = `${this.correctCount} phrase(s) réussie(s) sur ${this.completedCount} phrase(s) jouée(s).`
    }

    this.progressTarget.textContent = "Résultat"
  }

  finishActivity() {
    if (!this.hasFinishUrlValue) return

    if (this.hasFinishButtonTarget) {
      this.finishButtonTarget.disabled = true
      this.finishButtonTarget.textContent = "Validation..."
    }

    const form = document.createElement("form")
    form.method = "post"
    form.action = this.finishUrlValue
    form.style.display = "none"

    const methodInput = document.createElement("input")
    methodInput.type = "hidden"
    methodInput.name = "_method"
    methodInput.value = "patch"

    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = this.csrfToken()

    form.appendChild(methodInput)
    form.appendChild(csrfInput)

    document.body.appendChild(form)
    form.submit()
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

  updateProgress() {
    if (!this.hasProgressTarget) return

    if (this.modeValue === "word_learning") {
      this.progressTarget.textContent = `${this.completedCount} mot(s)`
    }

    if (this.modeValue === "sentence_completion") {
      this.progressTarget.textContent = `${this.correctCount} / ${this.completedCount}`
    }
  }

  shuffle(array) {
    return [...array].sort(() => Math.random() - 0.5)
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }

  normalize(value) {
    return value
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
  }
}
