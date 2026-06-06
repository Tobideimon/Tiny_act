import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    progressUrl: String,
    initialElapsed: Number,
    duration: Number
  }

  connect() {
    this.elapsedSeconds = this.initialElapsedValue || 0
    this.startedAt = Date.now()

    this.saveInterval = setInterval(() => {
      this.saveProgress()
    }, 5000)

    window.addEventListener("pagehide", this.saveBeforeLeaving)
    window.addEventListener("beforeunload", this.saveBeforeLeaving)
  }

  disconnect() {
    this.saveProgress()

    clearInterval(this.saveInterval)

    window.removeEventListener("pagehide", this.saveBeforeLeaving)
    window.removeEventListener("beforeunload", this.saveBeforeLeaving)
  }

  saveBeforeLeaving = () => {
    this.saveProgressWithBeacon()
  }

  currentElapsedSeconds() {
    const secondsSinceLoad = Math.floor((Date.now() - this.startedAt) / 1000)
    return this.elapsedSeconds + secondsSinceLoad
  }

  saveProgress() {
    const elapsedSeconds = this.currentElapsedSeconds()

    fetch(this.progressUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": this.csrfToken(),
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({
        elapsed_seconds: elapsedSeconds
      })
    }).catch(() => {})
  }

  saveProgressWithBeacon() {
    const elapsedSeconds = this.currentElapsedSeconds()
    const csrfToken = this.csrfToken()

    const payload = JSON.stringify({
      elapsed_seconds: elapsedSeconds,
      authenticity_token: csrfToken
    })

    const blob = new Blob([payload], { type: "application/json" })

    navigator.sendBeacon(this.progressUrlValue, blob)
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }
}
