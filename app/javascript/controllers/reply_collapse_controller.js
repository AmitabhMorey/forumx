import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggleBtn", "indicator"]

  toggle() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.toggle("hidden")
      const isHidden = this.contentTarget.classList.contains("hidden")

      if (this.hasIndicatorTarget) {
        this.indicatorTarget.textContent = isHidden ? "[+]" : "[-]"
      }

      if (this.hasToggleBtnTarget) {
        this.toggleBtnTarget.setAttribute("aria-expanded", !isHidden)
      }
    }
  }
}
