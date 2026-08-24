#!/bin/bash

# macOS bootstrap for a fresh install.
#
# This script:
#   - Installs Homebrew and the minimal packages needed to talk to GitHub over SSH
#   - Generates an SSH key and registers it with GitHub
#   - Installs git-ext
#   - Clones the private `repos` repo and runs its setup script, which sets up
#     everything else, including this machine's config repo

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install git gh

"${REPO_ROOT}/github_ssh.sh"

curl -fsSL https://raw.githubusercontent.com/ryanburda/git-ext/main/install.sh | sh

"${REPO_ROOT}/run_repos_setup.sh"
