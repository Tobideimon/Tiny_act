import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startScreen",
    "runner",
    "finished",
    "launchButton",
    "nextButton",
    "finishButton",
    "currentStepNumber",
    "totalSteps",
    "currentStepText",
    "stepsData"
  ]

  static values = {
    finishUrl: String
  }

  connect() {
    this.currentIndex = 0
    this.steps = this.loadSteps()

    this.startScreenTarget.hidden = false
    this.runnerTarget.hidden = true
    this.finishedTarget.hidden = true

    if (this.hasTotalStepsTarget) {
      this.totalStepsTarget.textContent = this.steps.length
    }
  }

  launch() {
    if (this.steps.length === 0) return

    this.currentIndex = 0

    this.startScreenTarget.hidden = true
    this.runnerTarget.hidden = false
    this.finishedTarget.hidden = true

    this.showCurrentStep()
  }

  showCurrentStep() {
    const currentStep = this.steps[this.currentIndex]

    if (!currentStep) {
      this.showFinishedScreen()
      return
    }

    this.currentStepNumberTarget.textContent = this.currentIndex + 1
    this.totalStepsTarget.textContent = this.steps.length
    this.currentStepTextTarget.textContent = currentStep

    this.nextButtonTarget.textContent = this.isLastStep() ? "Terminer le parcours" : "Étape suivante"
  }

  nextStep() {
    if (this.isLastStep()) {
      this.showFinishedScreen()
      return
    }

    this.currentIndex += 1
    this.showCurrentStep()
  }

  showFinishedScreen() {
    this.startScreenTarget.hidden = true
    this.runnerTarget.hidden = true
    this.finishedTarget.hidden = false

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

  isLastStep() {
    return this.currentIndex >= this.steps.length - 1
  }

  loadSteps() {
    if (!this.hasStepsDataTarget) return []

    try {
      return JSON.parse(this.stepsDataTarget.textContent)
    } catch (_error) {
      return []
    }
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }
}
