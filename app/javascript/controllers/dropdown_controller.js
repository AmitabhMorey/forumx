import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.closeWithKeyboard = this.closeWithKeyboard.bind(this)
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
    document.addEventListener("keydown", this.closeWithKeyboard)
    document.addEventListener("click", this.closeOnClickOutside)
  }

  disconnect() {
    document.removeEventListener("keydown", this.closeWithKeyboard)
    document.removeEventListener("click", this.closeOnClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden")
    }
  }

  closeOnClickOutside(event) {
    if (this.hasMenuTarget && !this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape" && this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
