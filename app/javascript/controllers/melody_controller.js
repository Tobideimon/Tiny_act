import { Controller } from "@hotwired/stimulus"
import * as Tone from "tone"

export default class extends Controller {
  static targets = ["key", "status", "progress", "footer", "volume"]
  static values = { notes: Array, finishUrl: String }

  connect() {
    this.synth = new Tone.PolySynth(Tone.Synth).toDestination()
    this.synth.set({ oscillator: { type: "triangle" } })
    Tone.getDestination().volume.value = Tone.gainToDb(0.8)
    this.index = 0
    this.finished = false
    this.updateProgress()
    this.highlightNext()
  }

  disconnect() {
    if (this.synth) { this.synth.dispose(); this.synth = null }
  }

  async playKey(event) {
    if (this.finished) return
    const button = event.currentTarget
    const note = button.dataset.note

    await Tone.start()
    this.synth.triggerAttackRelease(note, "8n")

    if (note === this.notesValue[this.index]) {
      this.flash(button, "melody-key-correct")
      this.index += 1
      this.updateProgress()
      if (this.index >= this.notesValue.length) {
        this.complete()
      } else {
        this.highlightNext()
      }
    } else {
      this.flash(button, "melody-key-wrong")
    }
  }

  selectInstrument(event) {
    const type = event.currentTarget.dataset.instrument
    if (this.synth) this.synth.set({ oscillator: { type } })
    this.element.querySelectorAll(".melody-chip").forEach((chip) =>
      chip.classList.toggle("is-active", chip === event.currentTarget)
    )
  }

  setVolume(event) {
    const pct = Number(event.currentTarget.value) / 100
    Tone.getDestination().volume.value = pct === 0 ? -Infinity : Tone.gainToDb(pct)
  }

  highlightNext() {
    const expected = this.notesValue[this.index]
    this.keyTargets.forEach((key) =>
      key.classList.toggle("melody-key-next", key.dataset.note === expected)
    )
  }

  complete() {
    this.finished = true
    this.keyTargets.forEach((key) => key.classList.remove("melody-key-next"))
    if (this.hasStatusTarget) this.statusTarget.textContent = "Mélodie réussie !"
    if (this.hasFooterTarget) this.footerTarget.hidden = false
    setTimeout(() => this.finish(), 1500)
  }

  finish() {
    if (!this.hasFinishUrlValue) return
    const form = document.createElement("form")
    form.method = "post"
    form.action = this.finishUrlValue
    form.style.display = "none"
    form.insertAdjacentHTML("beforeend",
      `<input type="hidden" name="_method" value="patch">
       <input type="hidden" name="authenticity_token" value="${this.csrfToken()}">`)
    document.body.appendChild(form)
    form.submit()
  }

  updateProgress() {
    if (this.hasProgressTarget) {
      const n = Math.min(this.index + 1, this.notesValue.length)
      this.progressTarget.textContent = `Note ${n} / ${this.notesValue.length}`
    }
  }

  flash(button, className) {
    button.classList.add(className)
    setTimeout(() => button.classList.remove(className), 250)
  }

  csrfToken() {
    const t = document.querySelector("meta[name='csrf-token']")
    return t ? t.content : ""
  }
}
