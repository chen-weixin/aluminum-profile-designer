const CACHE_NAME = "aluminum-profile-designer-v1";
const APP_FILES = [
  "./",
  "./index.html",
  "./styles.css",
  "./manifest.json",
  "./icons/icon.svg",
  "./js/app.js",
  "./js/catalog.js",
  "./js/calculator.js",
  "./js/exporters.js",
  "./js/storage.js",
  "./js/preview.js"
];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_FILES)));
});

self.addEventListener("fetch", (event) => {
  event.respondWith(caches.match(event.request).then((cached) => cached || fetch(event.request)));
});
