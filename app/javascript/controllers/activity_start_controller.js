import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startWrapper",
    "startButton",
    "backButton",
    "pauseButton",
    "primaryAction",
    "finishAction"
  ]

  static values = {
    startUrl: String
  }

  connect() {
    this.started = false
    this.starting = false
    this.finished = false

    this.syncControls()

    this.boundHandleActivityFinished = this.handleActivityFinished.bind(this)
    this.element.addEventListener("activity:finished", this.boundHandleActivityFinished)

    this.boundSyncPrimaryActionLabel = this.syncPrimaryActionLabel.bind(this)
    this.element.addEventListener("activity:controls-changed", this.boundSyncPrimaryActionLabel)
  }

  disconnect() {
    this.element.removeEventListener("activity:finished", this.boundHandleActivityFinished)
    this.element.removeEventListener("activity:controls-changed", this.boundSyncPrimaryActionLabel)
  }

  async start() {
    if (this.started || this.starting) return

    this.starting = true

    if (this.hasStartButtonTarget) {
      this.startButtonTarget.disabled = true
      this.startButtonTarget.textContent = "Démarrage..."
    }

    const startSaved = await this.persistStart()

    if (!startSaved) {
      this.starting = false

      if (this.hasStartButtonTarget) {
        this.startButtonTarget.disabled = false
        this.startButtonTarget.textContent = "Commencer l’activité"
      }

      alert("Impossible de démarrer l’activité. Réessaie.")
      return
    }

    const launchButton = this.findInternalLaunchButton()

    if (launchButton) {
      launchButton.click()
    } else {
      this.scrollToPlayableArea()
    }

    this.markStarted()
  }

  async persistStart() {
    if (!this.hasStartUrlValue) return true

    try {
      const response = await fetch(this.startUrlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json"
        }
      })

      return response.ok
    } catch (error) {
      console.error("Activity start failed:", error)
      return false
    }
  }

  primaryAction() {
    if (!this.started || this.finished) return

    const internalPrimaryButton = this.findInternalPrimaryButton()

    if (!internalPrimaryButton) return

    internalPrimaryButton.click()

    window.setTimeout(() => {
      this.syncPrimaryActionLabel()
    }, 0)
  }

  markStarted() {
    if (this.started) return

    this.started = true
    this.starting = false
    this.finished = false

    this.element.classList.add("is-activity-started")
    this.element.classList.remove("is-activity-finished")

    this.syncControls()

    window.setTimeout(() => {
      this.syncPrimaryActionLabel()
    }, 0)
  }

  handleActivityFinished() {
    this.finished = true

    this.element.classList.add("is-activity-finished")

    this.syncControls()
  }

  syncControls() {
    if (this.hasStartWrapperTarget) {
      this.startWrapperTarget.hidden = this.started
    }

    if (this.hasBackButtonTarget) {
      this.backButtonTarget.hidden = this.started
    }

    if (this.hasPauseButtonTarget) {
      this.pauseButtonTarget.hidden = !this.started || this.finished
    }

    if (this.hasPrimaryActionTarget) {
      this.primaryActionTarget.hidden = !this.started || this.finished
    }

    if (this.hasFinishActionTarget) {
      this.finishActionTarget.hidden = !this.finished
    }

    this.syncPrimaryActionLabel()
  }

  syncPrimaryActionLabel() {
    if (!this.hasPrimaryActionTarget || this.finished) return

    const internalPrimaryButton = this.findInternalPrimaryButton()

    if (!internalPrimaryButton) return

    const label = internalPrimaryButton.textContent.trim()

    if (label.length > 0) {
      this.primaryActionTarget.textContent = label
    }

    this.primaryActionTarget.disabled = internalPrimaryButton.disabled
  }

  findInternalLaunchButton() {
    return this.element.querySelector(
      [
        "[data-language-activity-target='launchButton']",
        "[data-sport-activity-target='launchButton']",
        "[data-code-quiz-target='launchButton']",
        "[data-photo-activity-target='launchButton']",
        "[data-productivite-activity-target='launchButton']"
      ].join(",")
    )
  }

  findInternalPrimaryButton() {
    return this.element.querySelector(
      [
        "[data-language-activity-target='nextButton']",
        "[data-language-activity-target='submitButton']",
        "[data-sport-activity-target='nextButton']",
        "[data-code-quiz-target='nextButton']",
        "[data-photo-activity-target='nextButton']",
        "[data-productivite-activity-target='nextButton']"
      ].join(",")
    )
  }

  scrollToPlayableArea() {
    const playableArea = this.element.querySelector(
      ".culture-theme-list, .activity-show-panel, .drawing-activity-panel"
    )

    if (!playableArea) return

    playableArea.scrollIntoView({
      behavior: "smooth",
      block: "center"
    })
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }
}
