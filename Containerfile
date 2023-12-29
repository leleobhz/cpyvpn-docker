FROM docker.io/library/debian:stable-slim as base
ARG GRAALVM_VERSION=23.1.1

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt -y full-upgrade \
  && DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install iproute2 bash procps vpnc catatonit unzip ca-certificates curl \
# Based on https://github.com/graalvm/container/blob/master/graalpy-community/Dockerfile.debian \
  && mkdir -p /opt/graalpy \
  && curl --fail --silent --location --retry 3 https://github.com/oracle/graalpython/releases/download/graal-${GRAALVM_VERSION}/graalpy-community-${GRAALVM_VERSION}-linux-$(bash -c "test $(dpkg --print-architecture) == "amd64" && echo amd64 || (test $(dpkg --print-architecture) == "arm64" && echo aarch64)").tar.gz | gunzip | tar x -C /opt/graalpy --strip-components=1 \
  && apt -y purge curl \
  && apt -y clean autoclean \
  && apt -y autoremove \
  && rm -rf /var/lib/{cache,log}/ /var/lib/apt/lists/*

FROM base as git
ARG BRANCH=main
RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install git ca-certificates \
  && echo "Build for branch ${BRANCH}" \
  && git clone --single-branch --depth=1 --branch=${BRANCH} https://gitlab.com/cpvpn/cpyvpn.git /cpyvpn

FROM scratch
COPY --from=base / /
RUN addgroup --system cpyvpn \
  && adduser --system --verbose --disabled-password --gecos '' --home /cpyvpn --shell /bin/bash --ingroup root --ingroup cpyvpn cpyvpn \
  && install -d --owner=cpyvpn --group=cpyvpn --mode=0755 /var/run/vpnc \
  && echo '#!/bin/bash\n\necho ${PASSWORD}' > /usr/local/bin/printpass \
  && chmod 0755 /usr/local/bin/printpass
COPY --from=git --chown=cpyvpn /cpyvpn /cpyvpn
USER cpyvpn
ENV PYTHONPATH=/cpyvpn
ENV PATH=/opt/graalpy/bin:$PATH
ENV MODE=l
ENV ADDITIONAL_OPTIONS=
ENV LOGLEVEL=INFO
ENV INTERFACE=snxvpn
ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD graalpy -m cpyvpn.client ${ADDITIONAL_OPTIONS} --mode ${MODE} --user ${USER} --loglevel ${LOGLEVEL} --interface ${INTERFACE} --script /usr/share/vpnc-scripts/vpnc-script --passwd-script /usr/local/bin/printpass ${HOST}
