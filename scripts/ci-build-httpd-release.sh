#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_NUMBER:?Drone build number is required}"
: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_TAG:?Release tag is required}"
: "${DRONE_COMMIT_REF:?Git ref is required}"
: "${DRONE_COMMIT_SHA:?Commit SHA is required}"

if [ "$DRONE_BUILD_EVENT" != tag ] || [ "$DRONE_COMMIT_REF" != "refs/tags/$DRONE_TAG" ]; then
  printf '%s\n' 'HTTPD release builds require their matching Git tag event.' >&2
  exit 1
fi

base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/alpine:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
expected_alpine=${base_tag%_*}
httpd_version=$(awk '$1 == "ENV" && $2 == "HTTPD_VERSION" { print $3; exit }' Dockerfile)
expected_tag="${httpd_version}-${base_tag}"
image="localhost/httpd-release:${DRONE_BUILD_NUMBER}-${DRONE_COMMIT_SHA}"

if [ "$DRONE_TAG" != "$expected_tag" ]; then
  printf 'HTTPD release tag mismatch: expected %s, got %s.\n' "$expected_tag" "$DRONE_TAG" >&2
  exit 1
fi

if ! awk -v tag="v${DRONE_TAG}:" '$1 == "-" && $2 == tag { found = 1 } END { exit !found }' VERSION.md; then
  printf 'HTTPD release tag %s is not recorded in VERSION.md.\n' "$DRONE_TAG" >&2
  exit 1
fi

attempt=0
until docker info >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 60 ]; then
    printf '%s\n' 'Docker-in-Docker service did not become ready.' >&2
    exit 1
  fi
  sleep 1
done

docker build --pull --no-cache --tag "$image" .
image_id=$(docker image inspect --format '{{.Id}}' "$image")
printf 'HTTPD release source commit: %s\n' "$DRONE_COMMIT_SHA"
printf 'HTTPD release tag: %s\n' "$DRONE_TAG"
printf 'HTTPD release image ID: %s\n' "$image_id"
scripts/ci-smoke-httpd-image.sh "$image_id" "$expected_alpine" "$httpd_version"

umask 077
printf '%s\n' "$image_id" > .drone-httpd-image-id
printf '%s\n' "$DRONE_TAG" > .drone-httpd-image-tag
printf '%s\n' "$DRONE_COMMIT_SHA" > .drone-httpd-commit
