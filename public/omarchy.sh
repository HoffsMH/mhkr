#!/bin/sh
set -eu

repo_url='https://github.com/HoffsMH/infra.git'
infra_dir="$HOME/infra"

if [ -e "$infra_dir" ] && [ ! -d "$infra_dir/.git" ]; then
  printf '%s\n' "Refusing to replace existing non-Git directory: $infra_dir" >&2
  exit 1
fi

if [ -d "$infra_dir/.git" ]; then
  git -C "$infra_dir" pull --ff-only
else
  git clone "$repo_url" "$infra_dir"
fi

exec "$infra_dir/bootstrap-omarchy.sh"
