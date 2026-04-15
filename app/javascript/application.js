// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"


document.addEventListener("turbo:load", initializePhotoComparisons);
document.addEventListener("turbo:frame-load", initializePhotoComparisons);

function initializePhotoComparisons() {
  document.querySelectorAll("[data-photo-comparison]").forEach((comparison) => {
    if (comparison.dataset.initialized === "true") return;
    comparison.dataset.initialized = "true";

    const slider = comparison.querySelector("[data-photo-comparison-slider]");
    const overlay = comparison.querySelector("[data-photo-comparison-overlay]");
    const divider = comparison.querySelector("[data-photo-comparison-divider]");

    if (!slider || !overlay || !divider) return;

    const updateComparison = () => {
      const value = `${slider.value}%`;
      overlay.style.width = value;
      divider.style.left = value;
    };

    slider.addEventListener("input", updateComparison);
    updateComparison();
  });
}