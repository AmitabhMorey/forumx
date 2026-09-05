import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 4500)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-y-2", "transition", "duration-300")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
