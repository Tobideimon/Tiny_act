import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    room: Object,
    editable: Boolean
  }

  connect() {
    this.room = this.roomValue

    this.tileWidth = 65
    this.tileHeight = 35

    this.offsetX = 445
    this.offsetY = 190
    this.tileHeight += 3
    this.furnitureScale = 1.2
    this.furnitureOffsetX = 24
    this.furnitureOffsetY = 5

    this.dragMove = this.dragMove.bind(this)
    this.dragEnd = this.dragEnd.bind(this)

    this.renderRoom()
  }

  gridToIso(x, y) {
    return {
      x: this.offsetX + (x - y) * this.tileWidth / 2,
      y: this.offsetY + (x + y) * this.tileHeight / 2
    }
  }

  isoToGrid(screenX, screenY) {
    const x = (
      (screenY - this.offsetY) / (this.tileHeight / 2) +
      (screenX - this.offsetX) / (this.tileWidth / 2)
    ) / 2

    const y = (
      (screenY - this.offsetY) / (this.tileHeight / 2) -
      (screenX - this.offsetX) / (this.tileWidth / 2)
    ) / 2

    return {
      x: Math.floor(x),
      y: Math.floor(y)
    }
  }

  renderRoom() {
    this.element.querySelectorAll(".tile, .furniture").forEach(element => {
      element.remove()
    })

    for (let y = 0; y < this.room.height; y++) {
      for (let x = 0; x < this.room.width; x++) {
        const pos = this.gridToIso(x, y)

        const tile = document.createElement("div")
        tile.className = "tile"

        tile.style.position = "absolute"
        tile.style.left = `${pos.x - this.tileWidth / 2}px`
        tile.style.top = `${pos.y - this.tileHeight / 2}px`

        tile.style.width = `${this.tileWidth}px`
        tile.style.height = `${this.tileHeight}px`

        tile.style.border = "1px solid rgba(255, 0, 0, 0.4)"
        tile.style.background = "rgba(255, 0, 0, 0.10)"

        tile.style.clipPath = "polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%)"
        tile.style.pointerEvents = "none"

        this.element.appendChild(tile)
      }
    }

    this.room.furnitures.forEach(item => {
      this.renderFurniture(item)
    })
  }

  renderFurniture(item) {
    const pos = this.gridToIso(item.x, item.y)

    const visualWidth = item.width * this.tileWidth
    const visualHeight = item.height * this.tileHeight * 2

    console.log("[room] renderFurniture:start", {
      item,
      pos,
      visualWidth,
      visualHeight,
      furnitureScale: this.furnitureScale,
      furnitureOffsetX: this.furnitureOffsetX,
      furnitureOffsetY: this.furnitureOffsetY
    })

    // DEBUG : cases réellement occupées par le meuble
    for (let dy = 0; dy < item.height; dy++) {
      for (let dx = 0; dx < item.width; dx++) {
        const footprintPos = this.gridToIso(item.x + dx, item.y + dy)

        const footprintTile = document.createElement("div")
        footprintTile.className = "furniture-footprint"

        footprintTile.style.position = "absolute"
        footprintTile.style.left = `${footprintPos.x - this.tileWidth / 2}px`
        footprintTile.style.top = `${footprintPos.y - this.tileHeight / 2}px`
        footprintTile.style.width = `${this.tileWidth}px`
        footprintTile.style.height = `${this.tileHeight}px`
        footprintTile.style.zIndex = item.x + item.y - 1

        this.element.appendChild(footprintTile)
      }
    }

    const img = document.createElement("img")

    img.src = item.image_url
    img.className = "furniture"
    img.addEventListener("load", () => {
      console.log("[room] furniture image loaded", {
        id: item.id,
        src: img.src,
        naturalWidth: img.naturalWidth,
        naturalHeight: img.naturalHeight
      })
    })
    img.addEventListener("error", () => {
      console.warn("[room] furniture image failed to load", {
        id: item.id,
        src: img.src
      })
    })
    img.dataset.id = item.id
    img.dataset.x = item.x
    img.dataset.y = item.y

    img.style.position = "absolute"
    img.style.width = `${visualWidth}px`
    img.style.height = "auto"

    img.style.left = `${pos.x - visualWidth / 2 + this.furnitureOffsetX}px`
    img.style.top = `${pos.y - visualHeight + this.furnitureOffsetY}px`
    img.style.zIndex = item.x + item.y
    img.style.transform = `scale(${this.furnitureScale})`
    img.style.transformOrigin = "bottom center"

    console.log("[room] renderFurniture:styles", {
      id: item.id,
      src: img.src,
      width: img.style.width,
      height: img.style.height,
      left: img.style.left,
      top: img.style.top,
      transform: img.style.transform,
      transformOrigin: img.style.transformOrigin
    })

    img.addEventListener("pointerdown", (event) => {
      this.startDragging(event, item, img)
    })

    img.addEventListener("contextmenu", (event) => {
      this.removeFurniture(event, item, img)
    })

    this.element.appendChild(img)
    console.log("[room] renderFurniture:appended", {
      id: item.id,
      isConnected: img.isConnected,
      childCount: this.element.children.length
    })
  }

  startDragging(event, item, element) {
    console.log("drag start", item)
    if (!this.editableValue) return

    event.preventDefault()

    this.draggedItem = item
    this.draggedElement = element

    document.addEventListener("pointermove", this.dragMove)
    document.addEventListener("pointerup", this.dragEnd)
  }

  dragMove(event) {
    if (!this.draggedItem || !this.draggedElement) return

    const rect = this.element.getBoundingClientRect()

    const scaleX = rect.width / this.element.offsetWidth
    const scaleY = rect.height / this.element.offsetHeight

    const screenX = (event.clientX - rect.left) / scaleX
    const screenY = (event.clientY - rect.top) / scaleY

    const grid = this.isoToGrid(screenX, screenY)

    this.draggedOutsideGrid = this.isOutsideGrid(this.draggedItem, grid.x, grid.y)

    if (this.draggedOutsideGrid) {
      this.draggedElement.classList.remove("invalid-placement")
      this.draggedElement.classList.add("delete-placement")
      return
    }

    if (!this.canPlace(this.draggedItem, grid.x, grid.y)) {
      this.draggedElement.classList.remove("delete-placement")
      this.draggedElement.classList.add("invalid-placement")
      return
    }

    this.draggedElement.classList.remove("delete-placement")
    this.draggedElement.classList.remove("invalid-placement")

    const pos = this.gridToIso(grid.x, grid.y)
    const visualWidth = this.draggedItem.width * this.tileWidth
    const visualHeight = this.draggedItem.height * this.tileHeight * 2

    this.draggedItem.x = grid.x
    this.draggedItem.y = grid.y

    this.draggedElement.style.left = `${pos.x - visualWidth / 2 + this.furnitureOffsetX}px`
    this.draggedElement.style.top = `${pos.y - visualHeight + this.furnitureOffsetY}px`
    this.draggedElement.style.zIndex = grid.x + grid.y
  }

  dragEnd() {
    if (this.draggedOutsideGrid) {
      this.deleteFurniture(this.draggedItem, this.draggedElement)
      this.cleanupDrag()
      return
    }
    if (!this.draggedItem) return

    this.saveFurniturePosition(this.draggedItem)

    document.removeEventListener("pointermove", this.dragMove)
    document.removeEventListener("pointerup", this.dragEnd)

    this.draggedItem = null
    this.draggedElement = null
  }

  cleanupDrag() {
    document.removeEventListener("pointermove", this.dragMove)
    document.removeEventListener("pointerup", this.dragEnd)

    this.draggedItem = null
    this.draggedElement = null
    this.draggedOutsideGrid = false
  }

  saveFurniturePosition(item) {
    fetch(`/room_furnitures/${item.id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({
        room_furniture: {
          x: item.x,
          y: item.y,
          z: item.z || 0,
          rotation: item.rotation || 0
        }
      })
    })
  }

  csrfToken() {
    const token =
      document.querySelector("meta[name='csrf-token']")

    return token ? token.content : ""
  }

  canPlace(item, newX, newY) {
    if (newX < 0 || newY < 0) return false

    if (newX + item.width > this.room.width)
      return false

    if (newY + item.height > this.room.height)
      return false

    return !this.room.furnitures.some(other => {
      if (other.id === item.id) return false

      return (
        newX < other.x + other.width &&
        newX + item.width > other.x &&
        newY < other.y + other.height &&
        newY + item.height > other.y
      )
    })
  }

  isOutsideGrid(item, x, y) {
    return (
      x < 0 ||
      y < 0 ||
      x + item.width > this.room.width ||
      y + item.height > this.room.height
    )
  }

  deleteFurniture(item, element) {
    fetch(`/room_furnitures/${item.id}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": this.csrfToken()
      }
    }).then(response => {
      if (response.ok) {
        element.remove()
        this.room.furnitures = this.room.furnitures.filter(f => f.id !== item.id)
      }
    })
  }
}
