#!/bin/bash

# Arch Linux bootstrap for a fresh install.
#
# This script:
#   - Installs the minimal packages needed to talk to GitHub over SSH
#   - Generates an SSH key and registers it with GitHub
#   - Installs git-ext
#   - Clones the private `repos` repo and runs its setup script, which sets up
#     everything else, including this machine's config repo
#
# NOTE: Must be bash, not zsh -- this runs before zsh is installed.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -Syu rather than -Sy: syncing the package databases without also upgrading
# leaves the system in a partial-upgrade state, where newly installed packages
# link against libraries the machine doesn't have yet.
sudo pacman -Syu --needed --noconfirm git curl openssh github-cli zsh

"${REPO_ROOT}/github_ssh.sh"

# SSH works now, so stop using the HTTPS remote the README cloned this with.
"${REPO_ROOT}/use_ssh_remote.sh"

curl -fsSL https://raw.githubusercontent.com/ryanburda/git-ext/main/install.sh | sh

"${REPO_ROOT}/run_repos_setup.sh"
