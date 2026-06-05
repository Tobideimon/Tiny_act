import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "index"]
  static values = { currentIndex: Number }

  connect() {
    this.showCurrentSlide()
  }

  previous() {
    this.currentIndexValue = this.wrapIndex(this.currentIndexValue - 1)
    this.showCurrentSlide()
  }

  next() {
    this.currentIndexValue = this.wrapIndex(this.currentIndexValue + 1)
    this.showCurrentSlide()
  }

  wrapIndex(index) {
    const total = this.slideTargets.length

    return (index + total) % total
  }

  showCurrentSlide() {
    this.slideTargets.forEach((slide, index) => {
      const isActive = index === this.currentIndexValue

      slide.hidden = !isActive
      slide.classList.toggle("active", isActive)
    })

    if (this.hasIndexTarget) {
      this.indexTarget.textContent = this.currentIndexValue + 1
    }
  }
}
