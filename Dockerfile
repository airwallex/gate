FROM alpine:3.11 AS compile
RUN apk add --update \
    openjdk11 \
    && rm -rf /var/cache/apk
LABEL maintainer="sig-platform@spinnaker.io"
ENV GRADLE_USER_HOME /workspace/.gradle
ENV GRADLE_OPTS -Xmx4g
WORKDIR /workspace
COPY . /workspace
RUN ./gradlew --no-daemon gate-web:installDist -x test

FROM alpine:3.11 AS run
LABEL maintainer="sig-platform@spinnaker.io"
RUN apk --no-cache add --update bash openjdk11-jre
RUN addgroup -S -g 10111 spinnaker
RUN adduser -S -G spinnaker -u 10111 spinnaker
COPY --from=compile /workspace/gate-web/build/install/gate /opt/gate
RUN mkdir -p /opt/gate/plugins && chown -R spinnaker:nogroup /opt/gate/plugins
USER spinnaker
CMD ["/opt/gate/bin/gate"]
