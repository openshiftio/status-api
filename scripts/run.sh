#!/bin/bash

uwsgi --ini status-api.ini &

nginx -c /etc/nginx/nginx.conf

