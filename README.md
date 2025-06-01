# docker-valgrind-image
An image which includes valgrind and executes requested tests

docker build -t valgrind_image:latest -f Dockerfile .

```bash
docker run \
    --hostname valgrind-binary-runner \
    --name valgrind-binary-runner \
    --env-file .env \
    -e REQUIRED_PACKAGES="" \
    -e VALGRIND_ARGS="--leak-check=full" \
    -e BINARY_NAME="${BINARY_NAME}" \
    -e ROOT_ACCESS="false" \
    -v "${BINARY_FOLDER}":/valgrinduser/app:ro \
    -t \
    valgrind_image:latest
```

Note: Not affiliated with valgrind
