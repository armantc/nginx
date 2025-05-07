#!/bin/sh

DOMAIN=example.com
CERT_DIR="/etc/nginx/ssl/"

# اگر گواهی نیست، بساز
if [ ! -f "$CERT_DIR/fullchain.pem" ] || [ ! -f "$CERT_DIR/privkey.pem" ]; then
  echo "Self-signed cert not found. Creating temporary self-signed certificate..."

  mkdir -p "$CERT_DIR"

  openssl genrsa -out "$CERT_DIR/privkey.pem" 2048

  openssl req -x509 -new -nodes -key "$CERT_DIR/privkey.pem" \
    -sha256 -days 365 \
    -out "$CERT_DIR/fullchain.pem" \
    -subj "/CN=$DOMAIN"

  echo "Temporary self-signed certificate created."
else
  echo "Real or existing cert found. Skipping self-signed generation."
fi

# envsubst '$${SERVER_NAME} $${S3_PATH}' < /tmp/nginx.conf > /usr/local/openresty/nginx/conf/nginx.conf

# اجرای OpenResty
# exec /usr/local/openresty/bin/openresty -g "daemon off;"

exec "$@"
