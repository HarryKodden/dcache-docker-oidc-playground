#!/bin/bash
set -e

#!/bin/bash
set -e
shopt -s globstar
mkdir -p /etc/dcache
for file in /config/**/*; do
  if [ -f "$file" ]; then
    dest="/etc/dcache/${file#/config/}"
    mkdir -p "$(dirname "$dest")"
    envsubst < "$file" > "$dest"
  fi
done

mkdir -p "${DCACHE_STORAGE_PATH}"
dcache pool create "${DCACHE_STORAGE_PATH}/pool-1" pool1 dCacheDomain
dcache database update

chimera mkdir /home
chimera mkdir /home/user
chimera chown 1000:1000 /home/user

dcache start

sleep infinity
