FROM docker.io/library/python:3-slim as base
RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt -y full-upgrade \
  && DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install iproute2 bash procps vpnc catatonit \
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
ENV MODE=l
ENV ADDITIONAL_OPTIONS=
ENV LOGLEVEL=INFO
ENV INTERFACE=snxvpn
ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD python -m cpyvpn.client ${ADDITIONAL_OPTIONS} --mode ${MODE} --user ${USER} --loglevel ${LOGLEVEL} --interface ${INTERFACE} --script /usr/share/vpnc-scripts/vpnc-script --passwd-script /usr/local/bin/printpass ${HOST}
