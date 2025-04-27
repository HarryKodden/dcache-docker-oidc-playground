# Step : build dcache deb package
FROM maven AS builder

ARG DCACHE_VERSION=master
ENV DCACHE_HOME=/opt/dcache

RUN apt-get update && apt-get install -y git dpkg-dev debhelper bash-completion quilt
RUN mkdir -p ${DCACHE_HOME}
RUN git clone https://github.com/dCache/dcache.git ${DCACHE_HOME}

WORKDIR ${DCACHE_HOME}

RUN git checkout ${DCACHE_VERSION}
RUN mvn clean package -DskipTests -am -pl packages/fhs -P deb
RUN cp ${DCACHE_HOME}/packages/fhs/target/dcache_${DCACHE_VERSION}-1_all.deb /tmp/dcache.deb

# Step : Install package
FROM openjdk:slim

COPY --from=builder /tmp/dcache.deb /tmp/dcache.deb

RUN apt-get update && \
    apt-get install -y dpkg ssh-client ssl-cert rsyslog procps gettext-base && \
    dpkg -i /tmp/dcache.deb && \
    rm -f /tmp/dcache.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# This is a bit peculiar. In order to start pools you need x509 certificates.
# Eventhough you don't use them.
RUN mkdir -p /etc/grid-security
RUN mkdir -p /etc/grid-security/certificates

# Generate phony key and self-signed certificate to make pools start
RUN openssl genrsa 2048 > /etc/grid-security/hostkey.pem
RUN openssl req -x509 -days 1000 -new \
            -subj "/C=NL/ST=Amsterdam/O=SURF/OU=ODS/CN=localhost" \
            -key /etc/grid-security/hostkey.pem \
            -out /etc/grid-security/hostcert.pem

RUN cat <<'EOF' > /etc/grid-security/storage-authzdb
version 2.1

authorize user read-write 1000 1000 /home/user /
EOF

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
