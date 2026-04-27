# Install Path Security

The one-line install (`bash <(curl -s https://raw.githubusercontent.com/wrg32786/titus-os/main/install.sh)`) is fast — it's also the riskiest single thing about this project. Every user is running attacker-controlled code if the repo or DNS is ever compromised. This document explains the trust model, what `install.sh` actually does, and how to do a checksum-pinned install if your threat model requires more.

## What `install.sh` does

In one sentence: **copies a curated set of files from this repo into your current directory, asks before overwriting anything, and creates no symlinks.**

The full sequence:

1. Detects whether you're inside a git repo, a project directory, or your home folder
2. Asks where to install (defaults to current working directory)
3. Confirms before overwriting any existing file
4. Copies `system/`, `vault/templates/`, `skills/`, `hooks/`, `daemons/`, `.claude/`, `CLAUDE.md`, and stub vault folders into the destination
5. Creates an empty `vault/projects/`, `vault/people/`, `vault/concepts/`, `vault/memory/`, `vault/daily/` if they don't exist
6. Initializes a `.gitignore` if there isn't one
7. Prints a "you're done" message with the next-step instruction

It does **not**:
- Send any data anywhere
- Modify files outside the install directory
- Run any post-install scripts
- Install dependencies (there are none)
- Modify shell rc files or PATH
- Touch your existing git config
- Require sudo

## What you're trusting

Running `bash <(curl -s ...)` trusts:

1. **GitHub Pages / GitHub raw content delivery** — that the file you fetch matches what's in the repo at HEAD
2. **The repo maintainer** — that no malicious commit has landed unreviewed
3. **DNS** — that `raw.githubusercontent.com` resolves to GitHub
4. **TLS** — that nobody is in-the-middle on your connection

For most users on most networks, these are reasonable assumptions. For a few, they aren't.

## How to verify before running

### Option A — read the script first

```bash
curl -s https://raw.githubusercontent.com/wrg32786/titus-os/main/install.sh | less
```

The script is ~3KB and entirely shell. You can read it end-to-end in 2 minutes. Look for:
- Any URL it fetches besides the repo content
- Any path it writes outside `$INSTALL_DIR`
- Any `eval`, `exec`, `source` of remote content
- Any `sudo` or privilege escalation

If anything in the script surprises you, don't run it.

### Option B — pin to a specific commit SHA

If you trust commit `abc1234` but not main:

```bash
bash <(curl -s https://raw.githubusercontent.com/wrg32786/titus-os/abc1234/install.sh)
```

Then verify the SHA matches what you expect:

```bash
git ls-remote https://github.com/wrg32786/titus-os main
```

### Option C — clone and install locally

```bash
git clone https://github.com/wrg32786/titus-os
cd titus-os
git log -1   # verify the latest commit
bash install.sh
```

This trusts the repo content but eliminates the curl-pipe-bash pattern entirely. You can also run `git diff` against a previous commit you've already audited.

### Option D — checksum-pinned

The maintainer publishes a SHA256 of `install.sh` at each tagged release in [`RELEASE_LOG.md`](../RELEASE_LOG.md). To verify before running:

```bash
curl -s https://raw.githubusercontent.com/wrg32786/titus-os/v0.2.0/install.sh -o /tmp/titus-install.sh
sha256sum /tmp/titus-install.sh   # compare to the SHA in RELEASE_LOG.md
bash /tmp/titus-install.sh
```

If the published checksum matches what you compute, you're running exactly what the maintainer intended at that release.

## Cryptographic signing roadmap

Tagged releases are not yet signed (sigstore or GPG). This is on the v0.3 roadmap. Until then, the four options above are your verification surface.

## Reporting an install-path vulnerability

Any of these counts:

- A path traversal issue in `install.sh` that writes outside `$INSTALL_DIR`
- Behavior that fetches URLs not under the user's control
- Silent overwrite of files without confirmation
- Embedded credentials or telemetry

See [`SECURITY.md`](../SECURITY.md) for how to report privately.
