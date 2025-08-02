#!/bin/bash

# Set isolate environment variables
export BOX_ROOT=/var/local/lib/isolate

# Ensure isolate permissions are correct
if [ ! -d "/var/local/lib/isolate" ] || [ "$(stat -c '%U' /var/local/lib/isolate)" != "judge0" ]; then
    echo "Fixing isolate permissions..."
    sudo mkdir -p /var/local/lib/isolate
    sudo chown -R judge0:judge0 /var/local/lib/isolate
    sudo chmod -R 755 /var/local/lib/isolate
    sudo -u judge0 BOX_ROOT=/var/local/lib/isolate isolate --init
fi

sudo cron
exec "$@"
