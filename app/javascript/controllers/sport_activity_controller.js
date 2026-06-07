import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "stepsPreview",
    "launchButton",
    "runner",
    "finished",
    "runnerLabel",
    "currentStepNumber",
    "totalSteps",
    "currentStepText",
    "timerWrapper",
    "timer",
    "nextButton",
    "finishButton"
  ]

  static values = {
    plan: Object,
    finishUrl: String
  }

  connect() {
    this.currentIndex = 0
    this.timerInterval = null
    this.stage = "idle"
    this.mainStepCount = this.mainSteps.length

    if (this.hasTotalStepsTarget) {
      this.totalStepsTarget.textContent = this.mainStepCount
    }
  }

  launch() {
    if (this.mainStepCount === 0) return

    this.stepsPreviewTarget.classList.add("is-hidden")
    this.launchButtonTarget.classList.add("is-hidden")
    this.runnerTarget.classList.remove("is-hidden")
    this.finishedTarget.classList.add("is-hidden")

    this.currentIndex = 0
    this.showPreparation()
  }

  showPreparation() {
    this.clearTimer()

    this.stage = "preparation"
    this.runnerLabelTarget.textContent = "Début dans :"
    this.currentStepTextTarget.textContent = "Prépare-toi"
    this.nextButtonTarget.textContent = "Passer la préparation"
    this.nextButtonTarget.classList.remove("is-hidden")

    this.startTimer(this.preparationSeconds, () => {
      this.startMainActivity()
    })
  }

  startMainActivity() {
    this.clearTimer()

    this.stage = "main"
    this.currentIndex = 0

    this.showCurrentStep()
  }

  showCurrentStep() {
    this.clearTimer()

    const currentStep = this.mainSteps[this.currentIndex]

    if (!currentStep) {
      this.showFinishedScreen()
      return
    }

    this.runnerLabelTarget.innerHTML = `Étape ${this.currentIndex + 1} / ${this.mainStepCount}`
    this.currentStepTextTarget.textContent = currentStep.text
    this.nextButtonTarget.textContent = this.isLastStep() ? "Terminer le parcours" : "Passer cette étape"
    this.nextButtonTarget.classList.remove("is-hidden")

    const duration = Number(currentStep.duration_seconds || 0)

    if (duration > 0) {
      this.startTimer(duration, () => {
        this.nextStep()
      })
    } else {
      this.timerWrapperTarget.classList.add("is-hidden")
      this.timerTarget.textContent = ""
    }
  }

  nextStep() {
    this.clearTimer()

    if (this.stage === "preparation") {
      this.startMainActivity()
      return
    }

    if (this.stage !== "main") return

    if (this.isLastStep()) {
      this.showFinishedScreen()
      return
    }

    this.currentIndex += 1
    this.showCurrentStep()
  }

  showFinishedScreen() {
    this.clearTimer()

    this.stage = "finished"
    this.runnerTarget.classList.add("is-hidden")
    this.finishedTarget.classList.remove("is-hidden")

    if (this.hasTimerWrapperTarget) {
      this.timerWrapperTarget.classList.add("is-hidden")
    }

    if (this.hasFinishButtonTarget) {
      this.finishButtonTarget.disabled = false
      this.finishButtonTarget.textContent = "Terminer"
    }
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

  startTimer(seconds, onComplete = null) {
    let remainingSeconds = Math.max(0, Number(seconds || 0))

    this.timerWrapperTarget.classList.remove("is-hidden")
    this.updateTimerDisplay(remainingSeconds)

    if (remainingSeconds <= 0) {
      if (typeof onComplete === "function") onComplete()
      return
    }

    this.timerInterval = setInterval(() => {
      remainingSeconds -= 1
      this.updateTimerDisplay(remainingSeconds)

      if (remainingSeconds <= 0) {
        this.clearTimer()

        if (typeof onComplete === "function") {
          onComplete()
        }
      }
    }, 1000)
  }

  clearTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  updateTimerDisplay(seconds) {
    const safeSeconds = Math.max(0, Number(seconds || 0))
    const minutes = Math.floor(safeSeconds / 60)
    const remainingSeconds = safeSeconds % 60

    this.timerTarget.textContent = `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`
  }

  isLastStep() {
    return this.currentIndex >= this.mainStepCount - 1
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }

  get plan() {
    return this.planValue || {}
  }

  get mainSteps() {
    return Array.isArray(this.plan.steps) ? this.plan.steps : []
  }

  get preparationSeconds() {
    return Number(this.plan.preparation_seconds || 30)
  }
}
