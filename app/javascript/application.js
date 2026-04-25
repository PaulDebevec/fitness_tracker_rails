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

document.addEventListener("turbo:load", initializeThemePreview);

function initializeThemePreview() {
  const modeSelect = document.querySelector("[data-theme-mode-select]");
  const colorSelect = document.querySelector("[data-theme-color-select]");
  const body = document.body;

  if (!modeSelect || !colorSelect || !body) return;

  const modeClasses = ["theme-mode-light", "theme-mode-dark", "theme-mode-system"];
  const colorClasses = [
    "theme-color-default",
    "theme-color-ocean",
    "theme-color-forest",
    "theme-color-sunset"
  ];

  function updatePreview() {
    body.classList.remove(...modeClasses, ...colorClasses);
    body.classList.add(`theme-mode-${modeSelect.value}`);
    body.classList.add(`theme-color-${colorSelect.value}`);
  }

  modeSelect.addEventListener("change", updatePreview);
  colorSelect.addEventListener("change", updatePreview);
}