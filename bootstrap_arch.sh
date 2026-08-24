#!/bin/bash

# Arch Linux bootstrap for a fresh install.
#
# This script:
#   - Installs the minimal packages needed to talk to GitHub over SSH
#   - Generates an SSH key and registers it with GitHub
#   - Installs git-ext
#
# From here, clone the `repos` repo over SSH and run its setup script to set
# up everything else, including this machine's config repo.
#
# NOTE: Must be bash, not zsh -- this runs before zsh is installed.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo pacman -Sy
sudo pacman -S --needed --noconfirm git curl openssh github-cli zsh

"${REPO_ROOT}/github_ssh.sh"

curl -fsSL https://raw.githubusercontent.com/ryanburda/git-ext/main/install.sh | sh

echo ""
echo "Bootstrap complete. Next:"
echo "  git clone-bare git@github.com:ryanburda/repos.git ~/code/repos"
echo "  WT=\$(git -C ~/code/repos worktree-add base main)"
echo "  git -C ~/code/repos worktree lock \"\$WT\""
echo "  \$WT/setup.sh"
