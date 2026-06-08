import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "canvas",
    "placeholder",
    "sizeIndicator",
    "eraserButton",
    "expandButton"
  ]

  connect() {
    this.canvas = this.canvasTarget
    this.ctx = this.canvas.getContext("2d")

    this.drawing = false
    this.currentColor = "#111827"
    this.brushSize = 4
    this.isEraser = false

    this.history = []
    this.redoStack = []

    this.resize()
    this.saveState()
  }

  resize() {
    const previous = this.canvas.toDataURL()

    const rect = this.canvas.parentElement.getBoundingClientRect()
    const ratio = window.devicePixelRatio || 1

    this.canvas.width = rect.width * ratio
    this.canvas.height = rect.height * ratio

    this.canvas.style.width = `${rect.width}px`
    this.canvas.style.height = `${rect.height}px`

    this.ctx = this.canvas.getContext("2d")
    this.ctx.setTransform(ratio, 0, 0, ratio, 0, 0)
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"

    if (previous && previous !== "data:,") {
      const image = new Image()

      image.onload = () => {
        this.ctx.drawImage(image, 0, 0, rect.width, rect.height)
      }

      image.src = previous
    }
  }

  point(event) {
    const rect = this.canvas.getBoundingClientRect()

    return {
      x: event.clientX - rect.left,
      y: event.clientY - rect.top
    }
  }

  start(event) {
    event.preventDefault()

    this.hidePlaceholder()
    this.drawing = true

    const point = this.point(event)

    this.ctx.beginPath()
    this.ctx.moveTo(point.x, point.y)
  }

  move(event) {
    if (!this.drawing) return

    event.preventDefault()

    const point = this.point(event)

    this.ctx.strokeStyle = this.isEraser
      ? "#ffffff"
      : this.currentColor

    this.ctx.lineWidth = this.isEraser
      ? this.brushSize * 3
      : this.brushSize

    this.ctx.lineTo(point.x, point.y)
    this.ctx.stroke()
  }

  end() {
    if (!this.drawing) return

    this.drawing = false
    this.ctx.closePath()

    this.saveState()
  }

  hidePlaceholder() {
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add("is-hidden")
    }
  }

  selectColor(event) {
    const selectedButton = event.currentTarget

    this.currentColor = selectedButton.dataset.color
    this.isEraser = false

    this.element
      .querySelectorAll(".drawing-color.is-active")
      .forEach((button) => {
        button.classList.remove("is-active")
      })

    selectedButton.classList.add("is-active")

    if (this.hasEraserButtonTarget) {
      this.eraserButtonTarget.classList.remove("is-active")
    }
  }

  increaseSize() {
    this.brushSize = Math.min(this.brushSize + 2, 18)
    this.updateSize()
  }

  decreaseSize() {
    this.brushSize = Math.max(this.brushSize - 2, 2)
    this.updateSize()
  }

  updateSize() {
    if (this.hasSizeIndicatorTarget) {
      this.sizeIndicatorTarget.textContent = this.brushSize
    }
  }

  toggleEraser() {
    this.isEraser = !this.isEraser

    if (this.hasEraserButtonTarget) {
      this.eraserButtonTarget.classList.toggle(
        "is-active",
        this.isEraser
      )
    }
  }

  saveState() {
    this.history.push(this.canvas.toDataURL())
    this.redoStack = []

    if (this.history.length > 30) {
      this.history.shift()
    }
  }

  undo() {
    if (this.history.length <= 1) return

    const current = this.history.pop()

    this.redoStack.push(current)

    this.restoreState(
      this.history[this.history.length - 1]
    )
  }

  redo() {
    if (this.redoStack.length === 0) return

    const next = this.redoStack.pop()

    this.history.push(next)

    this.restoreState(next)
  }

  restoreState(dataUrl) {
    const image = new Image()
    const rect = this.canvas.getBoundingClientRect()

    image.onload = () => {
      this.ctx.clearRect(
        0,
        0,
        rect.width,
        rect.height
      )

      this.ctx.drawImage(
        image,
        0,
        0,
        rect.width,
        rect.height
      )

      this.hidePlaceholder()
    }

    image.src = dataUrl
  }

  toggleFullscreen() {
    const previous = this.canvas.toDataURL()

    this.element.classList.toggle("is-expanded")

    if (this.hasExpandButtonTarget) {
      this.expandButtonTarget.textContent =
        this.element.classList.contains("is-expanded")
          ? "↙ Rétrécir"
          : "⛶ Agrandir"
    }

    setTimeout(() => {
      this.resize()

      const image = new Image()
      const rect = this.canvas.getBoundingClientRect()

      image.onload = () => {
        this.ctx.drawImage(
          image,
          0,
          0,
          rect.width,
          rect.height
        )
      }

      image.src = previous
    }, 250)
  }
}
