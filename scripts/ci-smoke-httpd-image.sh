#!/usr/bin/env sh
set -eu

image_id=${1:?Usage: ci-smoke-httpd-image.sh <image-id> <alpine-release> <httpd-version>}
expected_alpine=${2:?Usage: ci-smoke-httpd-image.sh <image-id> <alpine-release> <httpd-version>}
expected_httpd=${3:?Usage: ci-smoke-httpd-image.sh <image-id> <alpine-release> <httpd-version>}
container_id=""

cleanup() {
  rc=$?
  trap - EXIT
  if [ -n "$container_id" ]; then
    docker container rm --force "$container_id" >/dev/null || rc=1
  fi
  exit "$rc"
}
trap cleanup EXIT

container_id=$(docker container create "$image_id")
docker container start "$container_id" >/dev/null

attempt=0
until docker container exec "$container_id" curl --fail --silent --show-error http://127.0.0.1/ >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 30 ]; then
    docker container logs "$container_id" >&2 || true
    printf '%s\n' 'HTTPD did not serve its default page within 30 seconds.' >&2
    exit 1
  fi
  sleep 1
done

actual_alpine=$(docker container exec "$container_id" cat /etc/alpine-release)
if [ "$actual_alpine" != "$expected_alpine" ]; then
  printf 'Alpine release mismatch: expected %s, got %s\n' "$expected_alpine" "$actual_alpine" >&2
  exit 1
fi

httpd_output=$(docker container exec "$container_id" httpd -v 2>&1)
case "$httpd_output" in
  *"Apache/$expected_httpd"*) ;;
  *) printf 'HTTPD version mismatch; expected Apache/%s, got:\n%s\n' "$expected_httpd" "$httpd_output" >&2; exit 1 ;;
esac

docker container exec "$container_id" httpd -t
printf 'HTTPD smoke checks passed: Alpine %s, Apache %s, HTTP response successful.\n' \
  "$actual_alpine" "$expected_httpd"
