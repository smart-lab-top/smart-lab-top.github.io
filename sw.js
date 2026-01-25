const CACHE_NAME = 'al-folio-cache-v1';

// Assets to cache immediately on install
const PRECACHE_URLS = [
  '/',
  '/assets/css/main.css',
  '/assets/js/common.js',
  '/assets/js/theme.js'
];

// Install event: cache core assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

// Activate event: clean up old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event: handle requests
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // 1. Handle Navigation (HTML) - Network First, then Cache
  // 1. Handle Navigation (HTML) - Stale While Revalidate
  // This ensures the user sees the page immediately (if cached) while we update it in the background.
  if (event.request.mode === 'navigate') {
    event.respondWith(
      caches.open(CACHE_NAME).then(cache => {
        return cache.match(event.request).then(cachedResponse => {
          const fetchPromise = fetch(event.request).then(networkResponse => {
            cache.put(event.request, networkResponse.clone());
            return networkResponse;
          }).catch(() => {
            // Network failed, nothing to update
          });
          return cachedResponse || fetchPromise;
        });
      })
    );
    return;
  }

  // 2. Handle External Resources (CDNs) - Stale While Revalidate
  // Checks if the request is for a different origin (external CDN)
  if (url.origin !== self.location.origin) {
    event.respondWith(
      caches.open(CACHE_NAME).then(cache => {
        return cache.match(event.request).then(cachedResponse => {
          const fetchPromise = fetch(event.request).then(networkResponse => {
            cache.put(event.request, networkResponse.clone());
            return networkResponse;
          }).catch(err => {
            // Network failed, nothing to update
            console.log('Fetch failed for external resource:', err);
          });
          return cachedResponse || fetchPromise;
        });
      })
    );
    return;
  }

  // 3. Handle Local Assets (CSS, JS, Images) - Cache First, then Network
  event.respondWith(
    caches.match(event.request).then(cachedResponse => {
      if (cachedResponse) {
        return cachedResponse;
      }
      return fetch(event.request).then(response => {
        return caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, response.clone());
          return response;
        });
      });
    })
  );
});
