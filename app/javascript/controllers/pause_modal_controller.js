import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  static values = {
    pauseUrl: String,
    resumeUrl: String,
    initialElapsed: Number
  }

  connect() {
    this.pageStartedAt = Date.now()
    this.paused = false
    this.pausedElapsedSeconds = this.initialElapsedValue || 0
  }

  open() {
    if (this.paused) return

    this.paused = true
    this.pausedElapsedSeconds = this.currentElapsedSeconds()

    this.savePause()

    this.modalTarget.hidden = false
    document.body.classList.add("activity-pause-modal-open")

    window.dispatchEvent(new CustomEvent("tiny-act:activity-paused"))
  }

  resume() {
    if (!this.paused) {
      this.closeModal()
      return
    }

    this.resumeActivity()
    this.closeModal()

    this.paused = false
    this.pageStartedAt = Date.now()
    this.initialElapsedValue = this.pausedElapsedSeconds

    window.dispatchEvent(new CustomEvent("tiny-act:activity-resumed"))
  }

  closeModal() {
    this.modalTarget.hidden = true
    document.body.classList.remove("activity-pause-modal-open")
  }

  currentElapsedSeconds() {
    if (this.paused) return this.pausedElapsedSeconds

    const secondsSinceLoad = Math.floor((Date.now() - this.pageStartedAt) / 1000)
    return (this.initialElapsedValue || 0) + secondsSinceLoad
  }

  savePause() {
    fetch(this.pauseUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": this.csrfToken(),
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({
        elapsed_seconds: this.pausedElapsedSeconds
      })
    }).catch(() => {})
  }

  resumeActivity() {
    fetch(this.resumeUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": this.csrfToken(),
        "Content-Type": "application/json",
        "Accept": "application/json"
      }
    }).catch(() => {})
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }
}
