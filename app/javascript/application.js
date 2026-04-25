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
    const wrapper = comparison.querySelector(".photo-comparison-image-wrap");

    if (!slider || !wrapper) return;

    const updateComparison = () => {
      wrapper.style.setProperty("--comparison-position", `${slider.value}%`);
    };

    slider.addEventListener("input", updateComparison);
    updateComparison();
  });
}

document.addEventListener("turbo:load", initializeUserMenu);

function initializeUserMenu() {
  const menu = document.querySelector(".user-menu");
  const button = document.querySelector("[data-user-menu-button]");

  if (!menu || !button || menu.dataset.initialized === "true") return;

  menu.dataset.initialized = "true";

  button.addEventListener("click", (event) => {
    event.stopPropagation();
    menu.classList.toggle("open");
  });

  document.addEventListener("click", () => {
    menu.classList.remove("open");
  });
}