import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startScreen",
    "runner",
    "finished",
    "stepsData",
    "currentStepNumber",
    "totalSteps",
    "currentStepText",
    "cameraInput",
    "previewWrapper",
    "preview",
    "nextButton"
  ]

  static values = {
    finishUrl: String
  }

  connect() {
    this.steps = JSON.parse(this.stepsDataTarget.textContent)
    this.currentStepIndex = 0

    this.totalStepsTarget.textContent = this.steps.length
    this.updateStep()
  }

  launch() {
    this.startScreenTarget.hidden = true
    this.runnerTarget.hidden = false
    this.finishedTarget.hidden = true

    this.currentStepIndex = 0
    this.updateStep()
  }

  nextStep() {
    this.currentStepIndex += 1
    this.clearPhotoPreview()

    if (this.currentStepIndex >= this.steps.length) {
      this.showFinished()
      return
    }

    this.updateStep()
  }

  showFinished() {
    this.startScreenTarget.hidden = true
    this.runnerTarget.hidden = true
    this.finishedTarget.hidden = false
  }

  updateStep() {
    this.currentStepNumberTarget.textContent = this.currentStepIndex + 1
    this.currentStepTextTarget.textContent = this.steps[this.currentStepIndex]

    if (this.currentStepIndex === this.steps.length - 1) {
      this.nextButtonTarget.textContent = "Voir le résultat"
    } else {
      this.nextButtonTarget.textContent = "Étape suivante"
    }
  }

  openCamera() {
    this.cameraInputTarget.click()
  }

  previewPhoto(event) {
    const file = event.target.files[0]
    if (!file) return

    const imageUrl = URL.createObjectURL(file)

    this.previewTarget.src = imageUrl
    this.previewWrapperTarget.hidden = false
  }

  clearPhotoPreview() {
    if (this.hasPreviewTarget) {
      this.previewTarget.removeAttribute("src")
    }

    if (this.hasPreviewWrapperTarget) {
      this.previewWrapperTarget.hidden = true
    }

    if (this.hasCameraInputTarget) {
      this.cameraInputTarget.value = ""
    }
  }

  finishActivity() {
    fetch(this.finishUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    }).then(() => {
      window.location.reload()
    })
  }
}
