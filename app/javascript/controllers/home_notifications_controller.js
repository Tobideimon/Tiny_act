import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.currentIndex = 0
    this.startX = 0
    this.endX = 0
    this.hasSwiped = false

    this.updateCards()

    this.element.addEventListener("pointerdown", this.handlePointerDown)
    this.element.addEventListener("pointerup", this.handlePointerUp)
    this.element.addEventListener("click", this.handleClick, true)

    console.log("home-notifications controller connected")
  }

  disconnect() {
    this.element.removeEventListener("pointerdown", this.handlePointerDown)
    this.element.removeEventListener("pointerup", this.handlePointerUp)
    this.element.removeEventListener("click", this.handleClick, true)
  }

  handlePointerDown = (event) => {
    this.startX = event.clientX
    this.hasSwiped = false
  }

  handlePointerUp = (event) => {
    this.endX = event.clientX

    const swipeDistance = this.endX - this.startX

    if (Math.abs(swipeDistance) < 45) return

    this.hasSwiped = true

    if (swipeDistance < 0) {
      this.next()
    } else {
      this.previous()
    }
  }

  handleClick = (event) => {
    if (!this.hasSwiped) return

    event.preventDefault()
    event.stopPropagation()

    this.hasSwiped = false
  }

  next() {
    if (this.cardTargets.length <= 1) return

    this.currentIndex = (this.currentIndex + 1) % this.cardTargets.length
    this.updateCards()
  }

  previous() {
    if (this.cardTargets.length <= 1) return

    this.currentIndex =
      (this.currentIndex - 1 + this.cardTargets.length) % this.cardTargets.length

    this.updateCards()
  }

  updateCards() {
    this.cardTargets.forEach((card, index) => {
      card.classList.remove("is-active", "is-next", "is-third", "is-hidden")

      const position =
        (index - this.currentIndex + this.cardTargets.length) %
        this.cardTargets.length

      if (position === 0) {
        card.classList.add("is-active")
      } else if (position === 1) {
        card.classList.add("is-next")
      } else if (position === 2) {
        card.classList.add("is-third")
      } else {
        card.classList.add("is-hidden")
      }
    })
  }
}
