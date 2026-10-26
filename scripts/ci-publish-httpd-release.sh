#!/usr/bin/env sh
set -eu

: "${DRONE_BUILD_EVENT:?Drone build event is required}"
: "${DRONE_TAG:?Release tag is required}"
: "${DRONE_COMMIT_REF:?Git ref is required}"
: "${DRONE_COMMIT_SHA:?Commit SHA is required}"
: "${HTTPD_IMAGE_REPO:?HTTPD image repository is required}"
: "${DOCKER_USERNAME:?Docker username secret is required}"
: "${DOCKER_PASSWORD:?Docker password secret is required}"

if [ "$DRONE_BUILD_EVENT" != tag ] || [ "$DRONE_COMMIT_REF" != "refs/tags/$DRONE_TAG" ]; then
  printf '%s\n' 'HTTPD release publication requires its matching Git tag event.' >&2
  exit 1
fi

image_id=$(cat .drone-httpd-image-id)
release_tag=$(cat .drone-httpd-image-tag)
release_commit=$(cat .drone-httpd-commit)
httpd_version=$(awk '$1 == "ENV" && $2 == "HTTPD_VERSION" { print $3; exit }' Dockerfile)
base_ref=$(awk '$1 == "FROM" && $2 ~ /^kernel528\/alpine:/ { print $2; exit }' Dockerfile)
base_tag=${base_ref##*:}
expected_tag="${httpd_version}-${base_tag}"

if [ "$release_tag" != "$DRONE_TAG" ] || [ "$release_tag" != "$expected_tag" ] || \
   [ "$release_commit" != "$DRONE_COMMIT_SHA" ]; then
  printf '%s\n' 'HTTPD release metadata does not match the Drone tag, source commit, or Dockerfile.' >&2
  exit 1
fi

case "$image_id" in
  sha256:*) ;;
  *) printf '%s\n' 'HTTPD release artifact does not contain an immutable image ID.' >&2; exit 1 ;;
esac

docker image inspect "$image_id" >/dev/null
release_ref="${HTTPD_IMAGE_REPO}:${release_tag}"
docker_config=$(mktemp -d)
cleanup() {
  rc=$?
  trap - EXIT
  rm -rf "$docker_config" || rc=1
  rm -f .drone-httpd-image-id .drone-httpd-image-tag .drone-httpd-commit || rc=1
  exit "$rc"
}
trap cleanup EXIT
export DOCKER_CONFIG=$docker_config
printf '%s' "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

if manifest_output=$(docker manifest inspect "$release_ref" 2>&1); then
  printf 'Refusing to overwrite immutable HTTPD release %s.\n' "$release_ref" >&2
  exit 1
else
  case "$manifest_output" in
    *MANIFEST_UNKNOWN*|*"manifest unknown"*|*"no such manifest"*) ;;
    *) printf 'Could not verify HTTPD release tag is unused: %s\n' "$manifest_output" >&2; exit 1 ;;
  esac
fi

docker image tag "$image_id" "$release_ref"
if [ "$(docker image inspect --format '{{.Id}}' "$release_ref")" != "$image_id" ]; then
  printf '%s\n' 'HTTPD release tag is not attached to the tested image ID.' >&2
  exit 1
fi

if push_output=$(docker image push "$release_ref" 2>&1); then
  printf '%s\n' "$push_output"
else
  printf '%s\n' "$push_output" >&2
  exit 1
fi
release_digest=$(printf '%s\n' "$push_output" | awk '$2 == "digest:" { print $3; exit }')
case "$release_digest" in
  sha256:*) printf 'Immutable HTTPD release digest: %s\n' "$release_digest" ;;
  *) printf '%s\n' 'Registry push succeeded without reporting a manifest digest.' >&2; exit 1 ;;
esac

httpd_series=${httpd_version%.*}
for alias in "$httpd_version" "$httpd_series" latest; do
  alias_ref="${HTTPD_IMAGE_REPO}:${alias}"
  docker image tag "$image_id" "$alias_ref"
  if [ "$(docker image inspect --format '{{.Id}}' "$alias_ref")" != "$image_id" ]; then
    printf 'HTTPD alias %s is not attached to the tested image ID.\n' "$alias" >&2
    exit 1
  fi
  if alias_push_output=$(docker image push "$alias_ref" 2>&1); then
    printf '%s\n' "$alias_push_output"
  else
    printf '%s\n' "$alias_push_output" >&2
    exit 1
  fi
  alias_digest=$(printf '%s\n' "$alias_push_output" | awk '$2 == "digest:" { print $3; exit }')
  if [ "$alias_digest" != "$release_digest" ]; then
    printf 'HTTPD alias %s digest %s differs from immutable digest %s.\n' \
      "$alias" "${alias_digest:-missing}" "$release_digest" >&2
    exit 1
  fi
done

printf 'Published %s from tested image %s; aliases %s, %s, and latest share the release digest.\n' \
  "$release_ref" "$image_id" "$httpd_version" "$httpd_series"
