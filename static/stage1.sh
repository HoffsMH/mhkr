#!/usr/bin/env bash
# Stage 1 of a new-machine bootstrap. Run by s0 only after it has checked this
# file's signature. Clones the public base toolkit and installs it; base's
# setup.d sets up the YubiKey so private toolkits can be cloned over ssh.
set -euo pipefail

BASE_REPO=https://github.com/HoffsMH/toolkit-base.git
toolkits=$HOME/infra/toolkits

sudo pacman -S --needed --noconfirm git stow

mkdir -p "$toolkits"
if [ -d "$toolkits/base/.git" ]; then
  git -C "$toolkits/base" pull --ff-only
else
  git clone "$BASE_REPO" "$toolkits/base"
fi

export PATH="$toolkits/base/home/bin:$PATH"
toolkit.install base
