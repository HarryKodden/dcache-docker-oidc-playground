#!/bin/bash
set -e
set -x
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
# Ensure the Unix home path exists for authzdb mappings
# Modify dcache user home to /home/user
# sed -i 's|/var/lib/dcache|/home/user|g' /etc/passwd
mkdir -p /home/user
chown 1000:1000 /home/user
# if [ ! -d "${DCACHE_STORAGE_PATH}/pool-1" ]; then
#   dcache pool create "${DCACHE_STORAGE_PATH}/pool-1" pool1 dCacheDomain
# fi
dcache database update

echo "Creating chimera directories..."
if ! chimera ls /home >/dev/null 2>&1; then
  echo "Creating /home in chimera"
  chimera mkdir /home || echo "Failed to create /home in chimera"
fi
if ! chimera ls /home/user >/dev/null 2>&1; then
  echo "Creating /home/user in chimera"
  chimera mkdir /home/user || echo "Failed to create /home/user in chimera"
fi
echo "Setting ownership of /home/user"
chimera chown 1000:1000 /home/user || echo "Failed to chown /home/user"

# Generate SSH host key for admin service if not present
if [ ! -f /etc/dcache/admin/ssh_host_rsa_key ]; then
  echo "Generating SSH host key for admin service..."
  mkdir -p /etc/dcache/admin
  openssl genrsa -out /etc/dcache/admin/ssh_host_rsa_key 2048
  # Generate public key in PEM format (dCache may handle conversion)
  openssl rsa -in /etc/dcache/admin/ssh_host_rsa_key -pubout -out /etc/dcache/admin/ssh_host_rsa_key.pub
fi
chown -R dcache:dcache /etc/dcache/admin

chown -R dcache:dcache /var/log/dcache
mkdir -p /var/run/dcache && chown -R dcache:dcache /var/run/dcache
mkdir -p /var/lib/dcache && chown -R dcache:dcache /var/lib/dcache

echo "Starting dCache in foreground mode..."
export PATH=/usr/share/dcache/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk

# Clean any stale PID files
rm -f /var/run/dcache/*.pid /var/lib/dcache/*.pid

# Kill any leftover Java processes from previous runs
pkill -9 java || true
sleep 2

# Run dCache BootLoader as dcache user
exec su-exec dcache /usr/bin/java \
  -server \
  -Xmx2048m \
  -XX:MaxDirectMemorySize=2048m \
  -Dsun.net.inetaddr.ttl=1800 \
  -Dorg.globus.tcp.port.range=20000,25000 \
  -Dorg.dcache.dcap.port=0 \
  -Dorg.dcache.ftp.log-aborted-transfers=true \
  -Dorg.dcache.net.tcp.portrange=33115:33145 \
  -Djava.security.krb5.realm= \
  -Djava.security.krb5.kdc= \
  -Djavax.security.auth.useSubjectCredsOnly=false \
  -Djava.security.auth.login.config=/etc/dcache/jgss.conf \
  -Dcontent.types.user.table=/etc/dcache/content-types.properties \
  -Dzookeeper.sasl.client=false \
  -Dcurator-dont-log-connection-problems=true \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath=/var/log/dcache/dCacheDomain-oom.hprof \
  -XX:+ExitOnOutOfMemoryError \
  -XX:+StartAttachListener \
  -javaagent:/usr/share/dcache/classes/aspectjweaver-1.9.24.jar \
  -Djava.net.preferIPv6Addresses=system \
  --add-opens=java.base/java.lang=ALL-UNNAMED \
  --add-opens=java.base/java.util=ALL-UNNAMED \
  --add-opens=java.base/java.net=ALL-UNNAMED \
  --add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
  --add-opens=java.base/java.text=ALL-UNNAMED \
  --add-opens=java.sql/java.sql=ALL-UNNAMED \
  --add-opens=java.base/java.math=ALL-UNNAMED \
  --add-opens=java.base/sun.nio.fs=ALL-UNNAMED \
  -Djava.awt.headless=true \
  -DwantLog4jSetup=n \
  -Dorg.bouncycastle.dh.allow_unsafe_p_value=true \
  -Ddcache.home=/usr/share/dcache \
  -Ddcache.paths.defaults=/usr/share/dcache/defaults \
  -cp "/usr/share/dcache/classes/*" \
  org.dcache.boot.BootLoader start dCacheDomain
