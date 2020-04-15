#!/bin/bash

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

read -p "Domain: " domain
read -p "Email: " email

staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "/etc/letsencrypt" ]; then
  read -p "Existing data found for $domain. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "/etc/letsencrypt/conf/options-ssl-nginx.conf" ] || [ ! -e "/etc/letsencrypt/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  sudo mkdir -p "/etc/letsencrypt/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf | sudo tee /etc/letsencrypt/conf/options-ssl-nginx.conf >/dev/null
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem | sudo tee /etc/letsencrypt/conf/ssl-dhparams.pem >/dev/null
  echo
fi

echo "### Requesting Let's Encrypt certificate for $domain ..."

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker run -it --rm --name certbot \
  -v "/etc/letsencrypt:/etc/letsencrypt" \
  -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
  -p 80:80 \
  -p 443:443 \
  certbot/certbot certonly \
    --standalone \
    -d $domain \
    $email_arg \
    $staging_arg
