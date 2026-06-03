import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
    "stepsPreview",
    "launchButton",
    "runner",
    "finished",
    "currentStepNumber",
    "totalSteps",
    "currentStepText",
    "timerWrapper",
    "timer"
  ]

  static values = {
    steps: Array
  }

  connect() {
    this.currentIndex = 0
    this.timerInterval = null

    if (this.hasTotalStepsTarget) {
      this.totalStepsTarget.textContent = this.stepsValue.length
    }
  }

  launch() {
    if (this.stepsValue.length === 0) return

    this.stepsPreviewTarget.classList.add("is-hidden")
    this.launchButtonTarget.classList.add("is-hidden")
    this.runnerTarget.classList.remove("is-hidden")
    this.finishedTarget.classList.add("is-hidden")

    this.currentIndex = 0
    this.showCurrentStep()
  }

  showCurrentStep() {
    this.clearTimer()

    const currentStep = this.stepsValue[this.currentIndex]
    const duration = this.durationFromText(currentStep.text)

    this.currentStepNumberTarget.textContent = this.currentIndex + 1
    this.currentStepTextTarget.textContent = currentStep.text

    if (duration > 0) {
      this.startTimer(duration)
    } else {
      this.timerWrapperTarget.classList.add("is-hidden")
      this.timerTarget.textContent = ""
    }
  }

  nextStep() {
    this.clearTimer()

    this.currentIndex += 1

    if (this.currentIndex >= this.stepsValue.length) {
      this.finish()
      return
    }

    this.showCurrentStep()
  }

  finish() {
    this.clearTimer()
    this.runnerTarget.classList.add("is-hidden")
    this.finishedTarget.classList.remove("is-hidden")
  }

  startTimer(seconds) {
    let remainingSeconds = seconds

    this.timerWrapperTarget.classList.remove("is-hidden")
    this.updateTimerDisplay(remainingSeconds)

    this.timerInterval = setInterval(() => {
      remainingSeconds -= 1
      this.updateTimerDisplay(remainingSeconds)

      if (remainingSeconds <= 0) {
        this.nextStep()
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
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60

    this.timerTarget.textContent = `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`
  }

  durationFromText(text) {
    const match = text
      .toLowerCase()
      .match(/(\d+)\s*(secondes?|sec|s|minutes?|min)/)

    if (!match) return 0

    const value = Number.parseInt(match[1], 10)
    const unit = match[2]

    if (unit.startsWith("min")) {
      return value * 60
    }

    return value
  }
}
