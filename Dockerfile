# Stage 1: Usar Debian slim como base y configurar Valgrind
FROM debian:12.11-slim AS og_debian_12_11-slim

ARG DEBIAN_FRONTEND=noninteractive

# Instalar valgrind y dependencias mínimas, luego remover paquetes innecesarios
RUN chsh root -s /bin/sh

RUN apt-get purge --allow-remove-essential --auto-remove -y \
        e2fsprogs \
        logsave \
        libss2 \
        libext2fs2 \
        libcom-err2 \
        bsdutils \
        bash \
        tzdata

RUN rm -rf /var/lib/apt/lists/* \
       /usr/share/doc/* \
       /usr/share/man/* \
       /usr/share/info/* \
       /usr/share/locale/* \
       /var/cache/* \
    && find /usr/lib -name '*.a' -delete \
    && find /usr/lib -name '*.la' -delete

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    echo "UTC" > /etc/timezone

FROM scratch AS debian_12_11-naked
COPY --from=og_debian_12_11-slim / /

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=valgrinduser
ARG UID=1000
ARG GID=1000


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        valgrind \
        libc6-dbg \
        procps && \
    rm -rf /var/lib/apt/lists/*


RUN groupadd -g ${GID} ${USERNAME} && \
    useradd \
        -u ${UID} \
        -g ${GID} \
        --home-dir /${USERNAME} \
        --no-create-home \
        --shell /bin/sh \
        --comment "Debian Valgrind User" \
        ${USERNAME} && \
    mkdir -p /${USERNAME} && \
    chown ${USERNAME}:${USERNAME} /${USERNAME}

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod a+x /usr/local/bin/entrypoint.sh

WORKDIR /${USERNAME}/app

ENTRYPOINT exec "/usr/local/bin/entrypoint.sh"


# Entrada por defecto
CMD ["valgrind", "--help"]
