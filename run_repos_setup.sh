#!/bin/bash

# Clone the private `repos` repo and hand off to its setup script, which sets
# up everything else on the machine, including the `config` repo.

set -e

# install.sh symlinks git-ext's commands here, but dotfiles (which put this on
# PATH permanently) haven't been stowed yet -- that happens inside `config`'s
# setup.sh, which `repos`' setup.sh runs.
export PATH="${HOME}/.local/bin:${PATH}"

ROOT_PATH="${HOME}/code/repos"

git clone-bare git@github.com:ryanburda/repos.git "$ROOT_PATH"
WT=$(git -C "$ROOT_PATH" worktree-add base main)
# worktree-add output is unreliable when the worktree already exists
WT="${ROOT_PATH}/base"
git -C "$ROOT_PATH" worktree lock "$WT"

"$WT/setup.sh"
