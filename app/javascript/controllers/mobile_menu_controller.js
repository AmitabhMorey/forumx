import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "backdrop"]

  connect() {
    this.closeOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener("keydown", this.closeOnEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.closeOnEscape)
  }

  open() {
    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.remove("hidden")
      this.drawerTarget.classList.add("flex")
      document.body.classList.add("overflow-hidden")
    }
  }

  close() {
    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.remove("flex")
      this.drawerTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
