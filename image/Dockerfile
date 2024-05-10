#checkov:skip=CKV_DOCKER_2:actions/runner does not provider a mechanism for checking the health of the service
FROM ubuntu:23.10

ENV CONTAINER_USER="runner" \
    CONTAINER_UID="10000" \
    CONTAINER_GROUP="runner" \
    CONTAINER_GID="10000" \
    CONTAINER_HOME="/actions-runner" \
    DEBIAN_FRONTEND="noninteractive" \
    ACTIONS_RUNNER_VERSION="2.316.1" \
    ACTIONS_RUNNER_PKG_SHA="d62de2400eeeacd195db91e2ff011bfb646cd5d85545e81d8f78c436183e09a8"

SHELL ["/bin/bash", "-e", "-u", "-o", "pipefail", "-c"]

RUN groupadd --gid ${CONTAINER_GID} --system ${CONTAINER_GROUP} && \
  useradd --uid ${CONTAINER_UID} --gid ${CONTAINER_GROUP} --create-home ${CONTAINER_USER} && \  
  mkdir --parents ${CONTAINER_HOME} && \
  chown --recursive ${CONTAINER_USER}:${CONTAINER_GROUP} ${CONTAINER_HOME} && \
  apt-get update && apt-get install --yes --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  jq \
  libicu-dev \
  libcap2-bin \
  lsb-release \
  sudo \
  uidmap \
  podman && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  curl --location "https://github.com/actions/runner/releases/download/v${ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz" \
  --output "actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz" && \
  echo "${ACTIONS_RUNNER_PKG_SHA}"  "actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz" | /usr/bin/sha256sum --check && \
  tar --extract --gzip --file="actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz" --directory="${CONTAINER_HOME}" && \
  rm --force "actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz"

COPY --chown=${CONTAINER_USER}:${CONTAINER_GROUP} --chmod=0755 image/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo "${CONTAINER_USER} ALL=(ALL:ALL) NOPASSWD: /usr/bin/podman info, /usr/bin/podman build, /usr/bin/podman push, /usr/bin/podman pull, /usr/bin/podman run" > /etc/sudoers.d/${CONTAINER_USER} && \
    chmod 0440 /etc/sudoers.d/${CONTAINER_USER}

RUN cd /usr/bin && ls -l | grep podman && chmod u+s /usr/bin/podman && ls -l /usr/bin/podman && chmod u+s /usr/bin/newuidmap

RUN usermod --add-subuids 100000-165535 --add-subgids 100000-165535 runner

RUN echo 1 && ls -l / && echo 2 && ls -l /home && echo 3 && ls -l -a /home/runner

USER ${CONTAINER_USER}

# test podman
RUN podman info

WORKDIR ${CONTAINER_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

