#!/bin/bash

DOMAIN="$1"

RUTA_CONFIG="/home/hosting/reevolutiva-net/$DOMAIN"
RUTA_VOL_WP="/home/hosting/$DOMAIN/wp"
RUTA_VOL_DB="/home/hosting/$DOMAIN/db"

mkdir -p /home/hosting/trasnfer/

mkdir -p /home/hosting/trasnfer/$DOMAIN

zip -r /home/hosting/trasnfer/$DOMAIN/$DOMAIN-conf.zip $RUTA_CONFIG/
zip -r /home/hosting/trasnfer/$DOMAIN/$DOMAIN-db.zip $RUTA_VOL_DB/
zip -r /home/hosting/trasnfer/$DOMAIN/$DOMAIN-wp.zip $RUTA_VOL_WP/