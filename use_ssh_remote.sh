#!/bin/bash

# Repoint this repo's origin at SSH.
#
# The README clones this repo over HTTPS -- it has to, since this runs before an
# SSH key exists. But HTTPS pushes need a credential helper, and nothing here
# sets one up, so the checkout is left effectively fetch-only: pulls work
# (the repo is public), pushes fail with "could not read Username".
#
# Once github_ssh.sh has registered a key, SSH is available, so switch over and
# match every other repo on the machine.
#
# Only the transport changes: the owner/repo path is preserved, so a fork still
# points at the fork. Anything that isn't a github.com HTTPS URL (an existing
# SSH remote, a different host) is left untouched. Safe to re-run.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

url=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)

case "$url" in
    https://github.com/*)
        path=${url#https://github.com/}
        path=${path%.git}
        git -C "$REPO_ROOT" remote set-url origin "git@github.com:${path}.git"
        echo "origin -> git@github.com:${path}.git"
        ;;
    "")
        echo "No origin remote found in ${REPO_ROOT}; leaving it alone." >&2
        ;;
    *)
        echo "origin is already ${url}; leaving it alone."
        ;;
esac
