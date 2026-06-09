import { Controller } from "@hotwired/stimulus"
import * as Tone from "tone"

export default class extends Controller {
  static targets = [
    "preview",
    "runner",
    "finished",
    "launchButton",
    "key",
    "status",
    "progress",
    "currentNote",
    "notePill",
    "finishButton",
    "volume"
  ]

  static values = {
    notes: Array,
    finishUrl: String
  }

  connect() {
    this.synth = new Tone.PolySynth(Tone.Synth).toDestination()
    this.synth.set({ oscillator: { type: "triangle" } })
    Tone.getDestination().volume.value = Tone.gainToDb(0.8)

    this.index = 0
    this.started = false
    this.finished = false

    this.updateProgress()
    this.updateCurrentNote()
    this.syncFinishButton()
  }

  disconnect() {
    if (this.synth) {
      this.synth.dispose()
      this.synth = null
    }
  }

  launch() {
    if (this.started) return

    this.started = true
    this.index = 0
    this.finished = false

    if (this.hasPreviewTarget) this.previewTarget.hidden = true
    if (this.hasRunnerTarget) this.runnerTarget.hidden = false
    if (this.hasFinishedTarget) this.finishedTarget.hidden = true

    this.updateProgress()
    this.updateCurrentNote()
    this.highlightNext()
    this.syncFinishButton()

    this.element.dispatchEvent(
      new CustomEvent("activity:started", {
        bubbles: true,
        detail: { showFinishAction: true }
      })
    )
  }

  async playKey(event) {
    if (!this.started || this.finished) return

    const button = event.currentTarget
    const note = button.dataset.note
    const expectedNote = this.notesValue[this.index]

    await Tone.start()
    this.synth.triggerAttackRelease(note, "8n")

    if (note === expectedNote) {
      this.flash(button, "melody-key-correct")
      this.markPill(this.index, "is-done")

      this.index += 1

      if (this.index >= this.notesValue.length) {
        this.complete()
      } else {
        this.updateProgress()
        this.updateCurrentNote()
        this.highlightNext()
      }
    } else {
      this.flash(button, "melody-key-wrong")
      this.showTemporaryStatus(`Ce n’est pas ${expectedNote}. Réessaie.`)
    }
  }

  selectInstrument(event) {
    const type = event.currentTarget.dataset.instrument

    if (this.synth) {
      this.synth.set({ oscillator: { type } })
    }

    this.element.querySelectorAll(".melody-chip").forEach((chip) => {
      chip.classList.toggle("is-active", chip === event.currentTarget)
    })
  }

  setVolume(event) {
    const pct = Number(event.currentTarget.value) / 100
    Tone.getDestination().volume.value = pct === 0 ? -Infinity : Tone.gainToDb(pct)
  }

  complete() {
    this.finished = true

    this.keyTargets.forEach((key) => key.classList.remove("melody-key-next"))

    if (this.hasRunnerTarget) this.runnerTarget.hidden = true
    if (this.hasFinishedTarget) this.finishedTarget.hidden = false

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = "Mélodie réussie."
    }

    this.updateProgress()
    this.syncFinishButton()

    this.element.dispatchEvent(
      new CustomEvent("activity:finished", {
        bubbles: true
      })
    )
  }

  finish() {
    if (!this.finished || !this.hasFinishUrlValue) return

    if (this.hasFinishButtonTarget) {
      this.finishButtonTarget.disabled = true
      this.finishButtonTarget.textContent = "Validation..."
    }

    const form = document.createElement("form")
    form.method = "post"
    form.action = this.finishUrlValue
    form.style.display = "none"

    form.insertAdjacentHTML(
      "beforeend",
      `<input type="hidden" name="_method" value="patch">
       <input type="hidden" name="authenticity_token" value="${this.csrfToken()}">`
    )

    document.body.appendChild(form)
    form.submit()
  }

  updateProgress() {
    if (!this.hasProgressTarget) return

    const current = this.finished
      ? this.notesValue.length
      : Math.min(this.index + 1, this.notesValue.length)

    this.progressTarget.textContent = `Note ${current} / ${this.notesValue.length}`
  }

  updateCurrentNote() {
    if (!this.hasCurrentNoteTarget) return

    const note = this.notesValue[this.index]

    this.currentNoteTarget.textContent = note || "✓"
  }

  highlightNext() {
    const expected = this.notesValue[this.index]

    this.keyTargets.forEach((key) => {
      key.classList.toggle("melody-key-next", key.dataset.note === expected)
    })

    this.notePillTargets.forEach((pill) => {
      const pillIndex = Number(pill.dataset.index)
      pill.classList.toggle("is-current", pillIndex === this.index)
    })

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = "Joue la note indiquée."
    }
  }

  markPill(index, className) {
    const pill = this.notePillTargets.find((target) => {
      return Number(target.dataset.index) === index
    })

    if (!pill) return

    pill.classList.remove("is-current")
    pill.classList.add(className)
  }

  syncFinishButton() {
    if (!this.hasFinishButtonTarget) return

    this.finishButtonTarget.hidden = false
    this.finishButtonTarget.disabled = !this.finished
  }

  showTemporaryStatus(message) {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent = message

    window.clearTimeout(this.statusTimeout)

    this.statusTimeout = window.setTimeout(() => {
      if (!this.finished) {
        this.statusTarget.textContent = "Joue la note indiquée."
      }
    }, 900)
  }

  flash(button, className) {
    button.classList.add(className)

    window.setTimeout(() => {
      button.classList.remove(className)
    }, 250)
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }
}
