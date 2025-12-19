# Step : build dcache deb package
FROM maven:3.9.5-eclipse-temurin-17 AS builder

ENV DCACHE_HOME=/opt/dcache

RUN apt-get update && apt-get install -y dpkg-dev debhelper bash-completion quilt
RUN mkdir -p ${DCACHE_HOME}
# Use local source in the build context instead of cloning from GitHub
RUN git clone https://github.com/dCache/dcache.git ${DCACHE_HOME}
# RUN git clone https://github.com/HarryKodden/dcache.git ${DCACHE_HOME}
# COPY dcache ${DCACHE_HOME}
RUN sed -i '/<dotGitDirectory>/a \                        <failOnNoGitDirectory>false</failOnNoGitDirectory>' ${DCACHE_HOME}/pom.xml

WORKDIR ${DCACHE_HOME}

RUN mvn clean package -DskipTests -P deb -Dgit.commit.id.skip=true -DfailOnNoGitDirectory=false -Dgit.commit.id.describe=unknown -pl '!org.dcache:system-test'
RUN cp ${DCACHE_HOME}/packages/fhs/target/dcache_*-1_all.deb /tmp/dcache.deb
RUN ar x /tmp/dcache.deb && mkdir -p /tmp/dcache-extracted && tar -xf data.tar.gz -C /tmp/dcache-extracted
RUN ls -la /tmp/dcache-extracted/usr/share/dcache/lib/
RUN ln -sf /tmp/dcache-extracted/usr/share/dcache/lib/services-daemon.sh /tmp/dcache-extracted/usr/share/dcache/lib/services.sh

# Step : Install package
FROM alpine:latest

RUN apk add openjdk17
RUN apk add openssl
RUN apk add bash gettext-envsubst coreutils su-exec

# Create dcache user
RUN adduser -D -s /bin/bash dcache

COPY --from=builder /tmp/dcache-extracted /tmp/dcache-extracted

RUN tar -cf - -C /tmp/dcache-extracted . | tar -xf - -C /

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
