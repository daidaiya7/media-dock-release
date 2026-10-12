#!/bin/sh
# Load the official release image without requiring a registry login.
set -eu
cd "$(dirname "$0")"
version=$(cat VERSION)
case "$version" in *[!0-9.]*|'') echo 'Invalid VERSION' >&2; exit 1 ;; esac
docker compose version >/dev/null
arch=$(docker info --format '{{.Architecture}}')
case "$arch" in x86_64|amd64) arch=amd64 ;; aarch64|arm64) arch=arm64 ;; *) echo "Unsupported Docker architecture: $arch" >&2; exit 1 ;; esac
file="mediadock-$version-linux-$arch.tar.gz"
base="https://github.com/daidaiya7/media-dock-release/releases/download/v$version"
mkdir -p .downloads
curl -fL --retry 3 "$base/$file" -o ".downloads/$file"
curl -fL --retry 3 "$base/SHA256SUMS.txt" -o .downloads/SHA256SUMS.txt
expected=$(awk -v name="$file" '$2 == name {print $1}' .downloads/SHA256SUMS.txt)
[ ${#expected} -eq 64 ] || { echo 'Missing image checksum' >&2; exit 1; }
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum ".downloads/$file" | awk '{print $1}')
else
  actual=$(shasum -a 256 ".downloads/$file" | awk '{print $1}')
fi
[ "$actual" = "$expected" ] || { echo 'Image checksum mismatch' >&2; exit 1; }
docker load -i ".downloads/$file"
if [ ! -f .env ]; then cp .env.example .env; fi
docker compose up -d --pull never
docker compose ps
printf '\nMediaDock started. Open http://127.0.0.1:59189/admin to initialize.\n'
printf 'Existing .env and data volumes were preserved.\n'
