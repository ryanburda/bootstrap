#!/bin/sh

# Bootstrap entry point for a machine with nothing on it but a package manager.
#
#   curl -fsSL https://raw.githubusercontent.com/ryanburda/bootstrap/main/install.sh | sh
#
# Installs git (the one thing needed to clone this repo), clones the repo, and
# hands off to bootstrap.sh, which does the actual work.
#
# Environment overrides:
#   BOOTSTRAP_HOME  where the repo is cloned  (default: ~/code/bootstrap)
#   BOOTSTRAP_REPO  clone URL                 (default: the GitHub HTTPS URL)
#
# NOTE: POSIX sh, and everything lives inside main() which is called on the
# last line -- a truncated download then does nothing instead of running half a
# script.

set -eu

REPO_URL=${BOOTSTRAP_REPO:-https://github.com/ryanburda/bootstrap.git}
DEST=${BOOTSTRAP_HOME:-"$HOME/code/bootstrap"}

die() {
    echo "install.sh: $*" >&2
    exit 1
}

# pacman needs root. Use sudo when we aren't already root -- and if sudo isn't
# installed either, there's nothing this script can do but say so.
as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo > /dev/null 2>&1; then
        sudo "$@"
    else
        die "need root to run '$*', but neither root nor sudo is available"
    fi
}

ensure_git_arch() {
    command -v git > /dev/null 2>&1 && return 0

    command -v pacman > /dev/null 2>&1 ||
        die "no pacman found; this bootstrap only supports Arch on Linux"

    # -Syu rather than -Sy: syncing the databases without upgrading leaves a
    # partial-upgrade state, where new packages link against libraries the
    # machine doesn't have yet. On a fresh install this is also the first full
    # upgrade, which is what you want before installing anything else.
    echo "Installing git..."
    as_root pacman -Syu --needed --noconfirm git
}

ensure_git_macos() {
    # /usr/bin/git exists as a stub even without the Command Line Tools, so
    # `command -v git` proves nothing here -- ask xcode-select instead.
    xcode-select -p > /dev/null 2>&1 && return 0

    echo "The Command Line Tools are required. Accept the dialog that opens,"
    echo "wait for it to finish, then re-run this installer."
    xcode-select --install > /dev/null 2>&1 || true
    exit 1
}

fetch_repo() {
    if [ -d "$DEST/.git" ]; then
        echo "Updating existing checkout at $DEST"
        git -C "$DEST" pull --ff-only ||
            echo "install.sh: warning: could not fast-forward $DEST; using it as-is" >&2
    elif [ -e "$DEST" ]; then
        die "$DEST exists but is not a git checkout; move it aside and retry"
    else
        echo "Cloning $REPO_URL into $DEST"
        mkdir -p "$(dirname "$DEST")"
        git clone --quiet "$REPO_URL" "$DEST"
    fi
}

# Piped into sh, this script's stdin is the pipe, already at EOF -- and children
# inherit it. bootstrap.sh prompts for an email address, a GitHub token, and
# possibly a device-login code, all of which would read EOF and spin. So point
# it back at the terminal.
hand_off() {
    [ -x "$DEST/bootstrap.sh" ] || die "expected $DEST/bootstrap.sh to be executable"

    if [ -t 0 ]; then
        exec "$DEST/bootstrap.sh"
    elif (exec 3< /dev/tty) 2>/dev/null; then
        exec "$DEST/bootstrap.sh" < /dev/tty
    else
        die "no terminal available; bootstrap.sh needs to prompt. Run it directly: $DEST/bootstrap.sh"
    fi
}

main() {
    case "$(uname)" in
        Darwin) ensure_git_macos ;;
        Linux)  ensure_git_arch ;;
        *)      die "unsupported OS: $(uname)" ;;
    esac

    fetch_repo
    hand_off
}

main "$@"
