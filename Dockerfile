FROM docker.io/library/node:lts-slim@sha256:48abc13a19400ca3985071e287bd405a1d99306770eb81d61202fb6b65cf0b57

ARG TARGETARCH

# renovate: datasource=github-releases depName=astral-sh/uv versioning=semver
ARG UV_VERSION="0.8.24"

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    # Python's configuration
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED="random" \
    # UV's configuration
    UV_COMPILE_BYTECODE=1 \
    UV_NO_CACHE=1 \
    UV_PYTHON_DOWNLOADS="automatic" \
    UV_LINK_MODE="copy" \
    # server mode
    SERVER_MODE="supergateway" \
    # supergateway configuration
    PORT=8080 \
    SSE_PATH="/sse" \
    MESSAGE_PATH="/message" \
    BASE_URL="http://localhost:8080" \
    # mcp-server-puppeteer configuration
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium" \
    DBUS_SESSION_BUS_ADDRESS="autolaunch:" \
    DOCKER_CONTAINER="true"

# Install poetry
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
      ca-certificates \
      chromium \
      curl \
      fonts-ipafont-gothic  \
      fonts-wqy-zenhei  \
      fonts-thai-tlwg  \
      fonts-kacst  \
      fonts-freefont-ttf \
      gnupg \
      libasound2 \
      libatk-bridge2.0-0 \
      libdrm2 \
      libgbm1 \
      libgtk2.0-0 \
      libxkbcommon0 \
      libxss1 \
      tini \
      wget; \
    case "${TARGETARCH}" in \
      'amd64') export ARCH='x86_64' ;; \
      'arm64') export ARCH='aarch64' ;; \
    esac; \
    curl -fsSL "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${ARCH}-unknown-linux-gnu.tar.gz" \
      | tar xzf - -C /usr/local/bin --strip-components=1; \
    uv --version; \
    apt-get -y purge \
      curl; \
    apt-get -y autoremove; \
    apt-get clean

# Copy root
COPY root/ /

RUN chown -R 1000:1000 /app

USER 1000

WORKDIR /app

RUN set -ex; \
    uv sync \
      --locked \
      --no-dev \
      --no-editable; \
    npm ci

LABEL org.opencontainers.image.source="https://github.com/erhardtconsulting/mcp-collection"
LABEL org.opencontainers.image.description="MCP collection with integrated supergateway"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]