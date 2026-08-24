#!/bin/bash

# Turn a brand new machine into one with SSH access to GitHub and git-ext
# installed, so that the `repos` repo can take over from there.
#
# NOTE: Must be bash since it runs before zsh is guaranteed to be installed.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname)" in
    Darwin)
        "${REPO_ROOT}/bootstrap_macos.sh"
        ;;
    Linux)
        "${REPO_ROOT}/bootstrap_arch.sh"
        ;;
    *)
        echo "Unsupported OS: $(uname)" >&2
        exit 1
        ;;
esac
