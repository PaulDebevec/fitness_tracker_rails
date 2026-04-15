// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"


document.addEventListener("turbo:load", initializePhotoTimelines);
document.addEventListener("turbo:frame-load", initializePhotoTimelines);

function initializePhotoTimelines() {
  document.querySelectorAll("[data-photo-timeline]").forEach((timeline) => {
    if (timeline.dataset.initialized === "true") return;
    timeline.dataset.initialized = "true";

    const photos = JSON.parse(timeline.dataset.photos || "[]");
    const slider = timeline.querySelector("[data-photo-timeline-slider]");
    const image = timeline.querySelector("[data-photo-timeline-image]");
    const dateLabel = timeline.querySelector("[data-photo-timeline-date]");

    if (!slider || !image || !dateLabel || photos.length === 0) return;

    const updateTimeline = () => {
      const selectedPhoto = photos[Number(slider.value)];
      if (!selectedPhoto) return;

      image.src = selectedPhoto.url;
      dateLabel.textContent = selectedPhoto.date;
    };

    slider.addEventListener("input", updateTimeline);
  });
}