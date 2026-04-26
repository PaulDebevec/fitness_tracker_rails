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
  const modeRadios = document.querySelectorAll("[data-theme-mode-radio]");
  const colorRadios = document.querySelectorAll("[data-theme-color-radio]");
  const body = document.body;

  if (modeRadios.length === 0 || colorRadios.length === 0 || !body) return;

  const modeClasses = ["theme-mode-light", "theme-mode-dark", "theme-mode-system"];
  const colorClasses = [
    "theme-color-default",
    "theme-color-ocean",
    "theme-color-forest",
    "theme-color-sunset"
  ];

  function selectedThemeMode() {
    const selectedRadio = document.querySelector("[data-theme-mode-radio]:checked");
    return selectedRadio ? selectedRadio.value : "system";
  }

  function selectedThemeColor() {
    const selectedRadio = document.querySelector("[data-theme-color-radio]:checked");
    return selectedRadio ? selectedRadio.value : "default";
  }

  function updatePreview() {
    body.classList.remove(...modeClasses, ...colorClasses);
    body.classList.add(`theme-mode-${selectedThemeMode()}`);
    body.classList.add(`theme-color-${selectedThemeColor()}`);
  }

  modeRadios.forEach((radio) => {
    radio.addEventListener("change", updatePreview);
  });

  colorRadios.forEach((radio) => {
    radio.addEventListener("change", updatePreview);
  });
}

document.addEventListener("turbo:load", initializeAppearanceAutoSave);

function initializeAppearanceAutoSave() {
  const form = document.querySelector("[data-auto-save-appearance-form]");
  if (!form) return;

  const themeInputs = form.querySelectorAll(
    "[data-theme-mode-radio], [data-theme-color-radio]"
  );

  themeInputs.forEach((input) => {
    input.addEventListener("change", () => {
      form.requestSubmit();
    });
  });
}