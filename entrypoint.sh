#!/bin/sh

# entrypoint.sh: Instala paquetes requeridos, limpia caches y ejecuta Valgrind

# Evitar error si no se define
: "${REQUIRED_PACKAGES}"
: "${VALGRIND_ARGS}"
: "${BINARY_NAME}"
: "${ROOT_ACCESS}"

# Actualizar e instalar paquetes requeridos si se especificaron
if [ -n "$REQUIRED_PACKAGES" ]; then
    # Convertir la lista en múltiples argumentos
    set -- $REQUIRED_PACKAGES
    apt-get update && \
    apt-get install -y --no-install-recommends "$@" && \
    rm -rf /var/lib/apt/lists/* \
           /usr/share/doc/* \
           /usr/share/man/* \
           /usr/share/info/*
fi

# Construir el comando Valgrind
VALGRIND_CMD=/usr/bin/valgrind

# Añadir args de Valgrind si existen
if [ -n "$VALGRIND_ARGS" ]; then
    # Desglozar VALGRIND_ARGS en múltiples argumentos
    set -- $VALGRIND_ARGS
    VALGRIND_CMD+=("$@")
fi

# Ruta al binario a ejecutar
VALGRIND_CMD+=("/valgrinduser/app/$BINARY_NAME")

# Ejecutar como root o valgrinduser
if [ "$ROOT_ACCESS" = "true" ]; then
    exec "${VALGRIND_CMD[@]}"
else
    exec su -s /bin/sh valgrinduser -c "${VALGRIND_CMD[*]}"
fi
