// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Configure Turbo progress bar delay to show instantly
if (window.Turbo) {
  Turbo.setProgressBarDelay(1)
}

// Dismiss initial screen preloader smoothly once DOM/scripts are loaded
function dismissInitialScreenLoader() {
  const preloader = document.getElementById("initial-screen-loader")
  if (!preloader) return

  setTimeout(() => {
    preloader.classList.add("opacity-0", "pointer-events-none", "scale-95")
    setTimeout(() => {
      preloader.style.display = "none"
    }, 500)
  }, 250)
}

if (document.readyState === "complete" || document.readyState === "interactive") {
  dismissInitialScreenLoader()
} else {
  window.addEventListener("DOMContentLoaded", dismissInitialScreenLoader)
  window.addEventListener("load", dismissInitialScreenLoader)
}

// Global Uiverse/Aceternity-style visual loader for Turbo transitions
function showLoader() {
  const loader = document.getElementById("global-page-loader")
  if (loader) {
    loader.classList.remove("opacity-0", "pointer-events-none")
    loader.classList.add("opacity-100")
  }
}

function hideLoader() {
  const loader = document.getElementById("global-page-loader")
  if (loader) {
    loader.classList.remove("opacity-100")
    loader.classList.add("opacity-0", "pointer-events-none")
  }
}

document.addEventListener("turbo:load", () => {
  dismissInitialScreenLoader()
  hideLoader()
})
document.addEventListener("turbo:before-visit", showLoader)
document.addEventListener("turbo:submit-start", showLoader)
document.addEventListener("turbo:submit-end", hideLoader)
document.addEventListener("turbo:before-fetch-request", showLoader)
document.addEventListener("turbo:before-fetch-response", hideLoader)

