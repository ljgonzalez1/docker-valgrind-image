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

# Definir comando base
CMD_VALGRIND="/usr/bin/valgrind"
TARGET_PATH="/valgrinduser/app/$BINARY_NAME"

# Construir lista de argumentos para Valgrind
if [ -n "$VALGRIND_ARGS" ]; then
    # VALGRIND_ARGS se expande como palabra única, pero dash dividirá en campos
    set -- $VALGRIND_ARGS
    ARGS_VALGRIND="$CMD_VALGRIND $* $TARGET_PATH"
else
    ARGS_VALGRIND="$CMD_VALGRIND $TARGET_PATH"
fi

# Ejecutar como root o valgrinduser
if [ "$ROOT_ACCESS" = "true" ]; then
    exec sh -c "$ARGS_VALGRIND"
else
    exec su -s /bin/sh valgrinduser -c "$ARGS_VALGRIND"
fi
