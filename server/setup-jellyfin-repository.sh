#!/usr/bin/env bash

set -euo pipefail

VERSION_OS="$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release )"
VERSION_CODENAME="$( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release )"
DPKG_ARCHITECTURE="$( dpkg --print-architecture )"

KEYRING_FILE="${KEYRING_FILE:-/etc/apt/trusted.gpg.d/jellyfin.gpg}"

echo "> Installing prerequisites."
apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg ca-certificates

echo "> Cleaning up APT cache."
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "> Creating APT keyring directory."
mkdir -p "$( dirname "${KEYRING_FILE}" )"

echo "> Fetching repository signing key."
curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key \
    | gpg --dearmor --yes --output "${KEYRING_FILE}"

echo "> Installing Jellyfin repository into APT."
cat <<EOF | tee /etc/apt/sources.list.d/jellyfin.sources
Types: deb
URIs: https://repo.jellyfin.org/${VERSION_OS}
Suites: ${VERSION_CODENAME}
Components: main
Architectures: ${DPKG_ARCHITECTURE}
Signed-By: ${KEYRING_FILE}
EOF
