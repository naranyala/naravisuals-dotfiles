#!/bin/bash

echo "🚀 Launching De-Googled Chromium..."

chromium \
  --disable-background-networking \
  --disable-sync \
  --disable-translate \
  --disable-default-apps \
  --disable-signin-promo \
  --disable-domain-reliability \
  --metrics-recording-only \
  --no-first-run \
  --disable-breakpad \
  --disable-client-side-phishing-detection \
  --disable-component-update \
  --disable-print-preview \
  --disable-search-geolocation-disclosure \
  --disable-web-resources \
  --disable-features=SafeBrowsingService,AutofillServerCommunication \
  --enable-features=WebGL,WidevineCdm \
  --restore-last-session

