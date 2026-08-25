#!/bin/bash

# Generate an SSH key and register it with GitHub.
#
# Safe to re-run: an existing key is reused rather than overwritten, and an
# existing gh session or already-registered key is left alone.
#
# NOTE: POSIX-ish bash, not zsh -- this runs before zsh is guaranteed to be
# installed.

set -e

echo "########################################"
echo "#          SSH Key Generation          #"
echo "########################################"
echo

KEY="${HOME}/.ssh/id_ed25519"

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

is_valid_email() {
    case "$1" in
        *@*.*) return 0 ;;
        *) return 1 ;;
    esac
}

if [[ -f "$KEY" ]]; then
    echo "${KEY} already exists, skipping keygen."
else
    while true; do
        read -r -p "Enter email address: " email
        if is_valid_email "$email"; then
            break
        fi
        echo "Invalid email address. Please try again."
    done

    ssh-keygen -t ed25519 -C "$email" -f "$KEY"
fi

# Cache the passphrase up front, if there is one. ~/.ssh/config does set
# AddKeysToAgent, but it isn't stowed until config's setup runs much later --
# nothing has written it yet at this point in the bootstrap. On Linux this is
# only useful if an agent is actually running.
if [[ $OSTYPE == darwin* ]]; then
    ssh-add --apple-use-keychain "$KEY"
elif [[ -n "$SSH_AUTH_SOCK" ]]; then
    ssh-add "$KEY"
fi

if ! gh auth status > /dev/null 2>&1; then
    echo
    echo "GitHub auth needed. Paste a classic personal access token scoped to"
    echo "admin:public_key (https://github.com/settings/tokens/new), or leave"
    echo "this blank to fall back to the interactive browser/device login."
    read -r -s -p "Token: " token
    echo
    if [[ -n "$token" ]]; then
        echo "$token" | gh auth login --hostname github.com --git-protocol ssh --with-token
    else
        gh auth login --hostname github.com --git-protocol ssh --scopes admin:public_key
    fi
fi

HOSTNAME=$(uname -n)

if gh ssh-key list 2>/dev/null | grep -qF "$(cut -d' ' -f2 < "${KEY}.pub")"; then
    echo "Public key already registered with GitHub."
elif ! gh ssh-key add "${KEY}.pub" --title "$HOSTNAME"; then
    echo "Could not upload the key. Grant the scope and retry:"
    echo "  gh auth refresh -s admin:public_key && gh ssh-key add ${KEY}.pub --title ${HOSTNAME}"
    exit 1
fi

# Verify. `ssh -T` against GitHub exits non-zero even on success.
ssh -o StrictHostKeyChecking=accept-new -T git@github.com || true
