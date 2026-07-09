#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo"

if command -v git-crypt >/dev/null 2>&1; then
  git-crypt "$@"
else
  nix-shell -p git-crypt --run "cd '$repo' && git-crypt $(printf '%q ' "$@")"
fi
