import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    console.log("[inventory] toggle", {
      hasPanelTarget: this.hasPanelTarget,
      panelTarget: this.hasPanelTarget ? this.panelTarget : null
    })

    if (!this.hasPanelTarget) return

    this.panelTarget.classList.toggle("open")
  }

  close() {
    if (!this.hasPanelTarget) return

    this.panelTarget.classList.remove("open")
  }
}
