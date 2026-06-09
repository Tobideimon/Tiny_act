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
    "downloadLink",
    "finishedPreviewWrapper",
    "finishedPreview",
    "finishedDownloadLink",
    "nextButton"
  ]

  connect() {
    this.steps = JSON.parse(this.stepsDataTarget.textContent)
    this.currentStepIndex = 0
    this.currentPhotoUrl = null
    this.currentPhotoName = "tiny-act-photo.jpg"

    this.totalStepsTarget.textContent = this.steps.length
    this.updateStep()
  }

  disconnect() {
    this.revokeCurrentPhotoUrl()
  }

  launch() {
    this.startScreenTarget.hidden = true
    this.runnerTarget.hidden = false
    this.finishedTarget.hidden = true

    this.currentStepIndex = 0
    this.updateStep()
  }

  nextStep() {
    if (this.currentStepIndex >= this.steps.length - 1) {
      this.showFinished()
      return
    }

    this.currentStepIndex += 1
    this.clearPhotoPreview()

    this.updateStep()
  }

  showFinished() {
    this.startScreenTarget.hidden = true
    this.runnerTarget.hidden = true
    this.finishedTarget.hidden = false
    this.renderFinishedPhoto()

    this.element.dispatchEvent(
      new CustomEvent("activity:finished", { bubbles: true })
    )
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

    this.revokeCurrentPhotoUrl()

    this.currentPhotoUrl = URL.createObjectURL(file)
    this.currentPhotoName = file.name || "tiny-act-photo.jpg"

    this.previewTarget.src = this.currentPhotoUrl
    this.previewWrapperTarget.hidden = false
    this.syncDownloadLink(this.downloadLinkTarget)
  }

  clearPhotoPreview() {
    this.revokeCurrentPhotoUrl()

    if (this.hasPreviewTarget) {
      this.previewTarget.removeAttribute("src")
    }

    if (this.hasPreviewWrapperTarget) {
      this.previewWrapperTarget.hidden = true
    }

    if (this.hasDownloadLinkTarget) {
      this.downloadLinkTarget.hidden = true
      this.downloadLinkTarget.removeAttribute("href")
    }

    if (this.hasCameraInputTarget) {
      this.cameraInputTarget.value = ""
    }
  }

  renderFinishedPhoto() {
    if (!this.hasFinishedPreviewWrapperTarget) return

    if (!this.currentPhotoUrl) {
      this.finishedPreviewWrapperTarget.hidden = true
      return
    }

    this.finishedPreviewTarget.src = this.currentPhotoUrl
    this.finishedPreviewWrapperTarget.hidden = false
    this.syncDownloadLink(this.finishedDownloadLinkTarget)
  }

  syncDownloadLink(link) {
    if (!link || !this.currentPhotoUrl) return

    link.href = this.currentPhotoUrl
    link.download = this.downloadFilename()
    link.hidden = false
  }

  downloadFilename() {
    const extension = this.currentPhotoName.split(".").pop()
    const safeExtension = extension && extension.length <= 5 ? extension : "jpg"

    return `tiny-act-photo-${new Date().toISOString().slice(0, 10)}.${safeExtension}`
  }

  revokeCurrentPhotoUrl() {
    if (!this.currentPhotoUrl) return

    URL.revokeObjectURL(this.currentPhotoUrl)
    this.currentPhotoUrl = null
  }
}
