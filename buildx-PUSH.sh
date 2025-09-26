## https://unix.stackexchange.com/questions/748633/error-multiple-platforms-feature-is-currently-not-supported-for-docker-driver

docker buildx build --push --file Dockerfile.alp \
--platform linux/amd64,linux/arm64 \
--tag kertain/spotiflac-dl:3830c96 .
