# bootstrap

Takes a brand new machine all the way to fully set up:
- gets SSH access to GitHub
- installs [git-ext](https://github.com/ryanburda/git-ext)
- hands off to the private [repos](https://github.com/ryanburda/repos) repo,
which sets up all other repos

Public on purpose: there's nothing machine or account-specific in here, and
it needs to run before an SSH key exists, so it's fetched over plain HTTPS.

## Usage

```sh
git clone https://github.com/ryanburda/bootstrap.git ~/code/bootstrap
~/code/bootstrap/bootstrap.sh
```

## GitHub authentication

`github_ssh.sh` generates an `ed25519` key (skipped if one already exists) and
registers it with GitHub via `gh ssh-key add`. To do that, `gh` needs to be
authenticated first. Two ways to get there:

- **Personal access token (recommended for headless bootstraps).** Create a
  classic token at https://github.com/settings/tokens/new scoped to just
  `admin:public_key`, and have it on hand (e.g. in a password manager) when
  the script prompts for it. This makes the whole run non-interactive apart
  from that one paste.
- **Browser/device login.** Leave the token prompt blank and `gh auth login`
  falls back to its normal device-code flow: it prints a URL and a code you
  enter in a browser on any device (your phone works fine even if the machine
  being bootstrapped has no browser yet).

Re-running the script is safe: an existing key, an existing `gh` session, and
an already-registered key are all left alone.
