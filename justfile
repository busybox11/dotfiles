default:
  @just --list

dotfiles := justfile_directory()
default_crypt_key := home_directory() + "/dotfiles-git-crypt-key"
crypt := dotfiles + "/scripts/git/git-crypt-wrap.sh"

deploy-nixos hostname="":
  #!/usr/bin/env bash
  set -euo pipefail
  cd "{{dotfiles}}"

  if ! just crypt-check; then
    echo "error: secrets are locked; run: just crypt-unlock" >&2
    exit 1
  fi

  target_host="${hostname:-$(hostname)}"
  sudo nixos-rebuild switch --flake "{{dotfiles}}#$target_host"

# Export the symmetric key for use on another machine (transfer securely, never commit).
crypt-export key=default_crypt_key:
  #!/usr/bin/env bash
  set -euo pipefail
  key_path="{{key}}"
  mkdir -p "$(dirname "$key_path")"
  "{{crypt}}" export-key "$key_path"
  echo "exported to $key_path"

# Unlock encrypted files after clone (or after lock).
crypt-unlock key=default_crypt_key:
  #!/usr/bin/env bash
  set -euo pipefail
  "{{crypt}}" unlock "{{key}}"

# Re-encrypt secrets in the working tree.
crypt-lock:
  "{{crypt}}" lock

# List git-crypt protected files and whether they are encrypted.
crypt-status:
  "{{crypt}}" status -e

# Confirm secrets/secrets.nix is readable (required before nix builds).
crypt-check:
  #!/usr/bin/env bash
  set -euo pipefail
  secret="{{dotfiles}}/secrets/secrets.nix"
  if [[ ! -f "$secret" ]]; then
    echo "missing: secrets/secrets.nix" >&2
    exit 1
  fi
  if ! grep -q 'workGitEmail\|prometheusRemoteUrl' "$secret" 2>/dev/null; then
    echo "locked or invalid: secrets/secrets.nix" >&2
    exit 1
  fi

# Stage secrets with git-crypt on PATH.
secrets-add:
  #!/usr/bin/env bash
  set -euo pipefail
  cd "{{dotfiles}}"
  "{{crypt}}" status -e secrets/secrets.nix
  if command -v git-crypt >/dev/null 2>&1; then
    git add secrets/secrets.nix
  else
    nix-shell -p git-crypt --run "cd '{{dotfiles}}' && git add secrets/secrets.nix"
  fi
  ./githooks/pre-commit
  echo "staged secrets/secrets.nix (encrypted)"

# New machine: unlock and verify an existing clone.
crypt-bootstrap repo="{{dotfiles}}" key=default_crypt_key:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ ! -d "{{repo}}/.git" ]]; then
    echo "error: {{repo}} is not a git repo" >&2
    exit 1
  fi
  cd "{{repo}}"
  just --justfile "{{dotfiles}}/justfile" crypt-unlock key="{{key}}"
  just --justfile "{{dotfiles}}/justfile" crypt-check
  just --justfile "{{dotfiles}}/justfile" crypt-status
  echo "git-crypt ready in {{repo}}"
