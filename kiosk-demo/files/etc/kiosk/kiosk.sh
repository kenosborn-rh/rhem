#!/bin/bash

URL="file:///var/www/kiosk/index.html"

while true; do
  firefox \
    --kiosk \
    --no-remote \
    --new-instance \
    "${URL}"
  sleep 2
done

