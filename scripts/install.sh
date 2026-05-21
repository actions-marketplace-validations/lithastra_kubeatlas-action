#!/usr/bin/env bash
# install.sh — fetch a kubectl-atlas release archive and put the
# binary on PATH for later action steps.
#
# Inputs come in as environment variables so the caller (action.yml)
# does not interpolate user input into shell tokens — keeps the step
# safe against malicious "version" inputs.
#
#   KUBEATLAS_ACTION_VERSION   "latest" | a tag like "v1.2.0"
#
# Outputs (written to $GITHUB_OUTPUT):
#   version  the resolved tag (so workflows can echo it back)

set -euo pipefail

REPO="lithastra/kubeatlas"
WANT="${KUBEATLAS_ACTION_VERSION:-latest}"

resolve_latest() {
  curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p' | head -1
}

if [[ "${WANT}" == "latest" ]]; then
  WANT="$(resolve_latest)"
fi
if [[ -z "${WANT}" ]]; then
  echo "install.sh: could not resolve a kubectl-atlas version" >&2
  exit 1
fi
# Strip a leading "v" for the archive filename; keep the original
# for the URL path.
SEMVER="${WANT#v}"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH_RAW="$(uname -m)"
case "${ARCH_RAW}" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "install.sh: unsupported arch ${ARCH_RAW}" >&2; exit 1 ;;
esac

ARCHIVE="kubectl-atlas_${SEMVER}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${WANT}/${ARCHIVE}"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

echo "Downloading ${URL}"
curl -fsSL -o "${TMP}/${ARCHIVE}" "${URL}"

# Verify the sha256 against the release's checksums.txt so a
# corrupted or tampered download fails before we put it on PATH.
echo "Verifying sha256"
curl -fsSL -o "${TMP}/checksums.txt" \
  "https://github.com/${REPO}/releases/download/${WANT}/checksums.txt"
( cd "${TMP}" && grep -F "${ARCHIVE}" checksums.txt | sha256sum -c - )

tar -xzf "${TMP}/${ARCHIVE}" -C "${TMP}"
BIN_DIR="${HOME}/.kubeatlas-action/bin"
mkdir -p "${BIN_DIR}"
mv "${TMP}/kubectl-atlas" "${BIN_DIR}/kubectl-atlas"
chmod +x "${BIN_DIR}/kubectl-atlas"
echo "${BIN_DIR}" >> "${GITHUB_PATH}"

echo "Installed kubectl-atlas ${WANT} into ${BIN_DIR}"
echo "version=${WANT}" >> "${GITHUB_OUTPUT}"
