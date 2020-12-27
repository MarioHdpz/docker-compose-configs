#!/bin/bash

# 0 4 * * sun /bin/bash /home/ubuntu/renew-cert.sh

docker run --rm --name certbot-renewal \
  -v "/etc/letsencrypt:/etc/letsencrypt" \
  -v "/var/www/certbot:/var/www/certbot" \
  certbot/certbot renew \
    --webroot \
    -w /var/www/certbot

docker exec nginx nginx -s reload
