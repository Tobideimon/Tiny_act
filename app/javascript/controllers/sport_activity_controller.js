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
    "nextButton"
  ]

  static values = {
    plan: Object
  }

  connect() {
    this.currentIndex = 0
    this.timerInterval = null
    this.startedAt = null
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
    this.startedAt = null
    this.showPreparation()
  }

  showPreparation() {
    this.clearTimer()

    this.stage = "preparation"
    this.runnerLabelTarget.textContent = "Début dans :"
    this.currentStepTextTarget.textContent = "Prépare-toi"
    this.nextButtonTarget.classList.remove("is-hidden")

    this.startTimer(this.preparationSeconds, () => {
      this.startMainActivity()
    })
  }

  startMainActivity() {
    this.clearTimer()

    this.stage = "main"
    this.startedAt = Date.now()
    this.currentIndex = 0

    this.showCurrentStep()
  }

  showCurrentStep() {
    this.clearTimer()

    const currentStep = this.mainSteps[this.currentIndex]
    if (!currentStep) {
      this.finish()
      return
    }

    this.runnerLabelTarget.innerHTML = `Étape ${this.currentIndex + 1} / ${this.mainStepCount}`
    this.currentStepTextTarget.textContent = currentStep.text

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

    this.currentIndex += 1

    if (this.currentIndex >= this.mainStepCount) {
      if (this.mustLoopAgain()) {
        this.currentIndex = 0
        this.showCurrentStep()
        return
      }

      this.finish()
      return
    }

    this.showCurrentStep()
  }

  finish() {
    this.clearTimer()

    this.stage = "finished"
    this.runnerTarget.classList.add("is-hidden")
    this.finishedTarget.classList.remove("is-hidden")
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

  mustLoopAgain() {
    if (this.plan.repeat_mode !== "until_duration") return false
    if (!this.startedAt) return false

    const elapsedSeconds = Math.floor((Date.now() - this.startedAt) / 1000)
    return elapsedSeconds < this.targetDurationSeconds
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

  get targetDurationSeconds() {
    return Number(this.plan.target_duration_seconds || 0)
  }
}
