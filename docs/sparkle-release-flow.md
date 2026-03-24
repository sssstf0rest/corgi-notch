# Sparkle Release Flow

This repository uses Sparkle for in-app updates and GitHub Pages as the update feed host.

## Overview

- `CorgiNotch.app` embeds a fixed Sparkle feed URL:
  - `https://sssstf0rest.github.io/CorgiNotch/appcast.xml`
- GitHub Releases remain the human-facing release page.
- The `gh-pages` branch stores Sparkle update assets:
  - `appcast.xml`
  - release archives
  - Sparkle delta files
  - release notes markdown files
- A GitHub Actions workflow mirrors a published release archive into `gh-pages` and regenerates the appcast.

## One-Time Setup

### 1. Enable GitHub Pages

In the GitHub repository settings:

1. Open **Settings** → **Pages**
2. Set the source to the `gh-pages` branch
3. Publish from the branch root

The resulting public feed URL should be:

```text
https://sssstf0rest.github.io/CorgiNotch/appcast.xml
```

### 2. Generate Sparkle Keys

Fetch the Sparkle tools locally:

```bash
./scripts/release/fetch-sparkle-tools.sh .cache/sparkle
```

Generate a new keypair:

```bash
.cache/sparkle/bin/generate_keys
```

That command prints the public EdDSA key. Save it.

Export the private key to a file:

```bash
.cache/sparkle/bin/generate_keys -x sparkle_private_ed25519
```

### 3. Add GitHub Repository Variable and Secret

Add the Sparkle keys to the repository:

- Repository variable: `SPARKLE_PUBLIC_ED_KEY`
  - value: the public key printed by `generate_keys`
- Repository secret: `SPARKLE_PRIVATE_ED_KEY_BASE64`
  - value: base64-encoded contents of the exported private key file

Example:

```bash
base64 < sparkle_private_ed25519 | pbcopy
```

### 4. Confirm App Feed Configuration

The app reads these build settings at build time:

- `SPARKLE_APPCAST_URL`
- `SPARKLE_PUBLIC_ED_KEY`

`SPARKLE_APPCAST_URL` is already set in the Xcode project to:

```text
https://sssstf0rest.github.io/CorgiNotch/appcast.xml
```

`SPARKLE_PUBLIC_ED_KEY` is now committed in the Xcode project and embedded in normal builds by default.
You can still override it from the environment if you ever rotate keys.

## Release Process

### 1. Bump the App Version

Before creating a release:

1. Update `MARKETING_VERSION`
2. Update `CURRENT_PROJECT_VERSION`
3. Commit the version bump

Sparkle compares `CFBundleVersion`, so the build number must always increase.

### 2. Build a Signed Release Archive

On a Mac configured for release signing, build the archive:

```bash
./scripts/release/build-release-archive.sh
```

The script creates a Sparkle archive like:

```text
build/sparkle-release/CorgiNotch-2.2.4.zip
```

Notes:

- The script expects your local Xcode signing setup to already be able to archive a release build.
- It verifies the archived app with `codesign --verify`.
- If you notarize release artifacts in your distribution process, do that before uploading the final zip.
- If you ever rotate the Sparkle key, you can temporarily override the embedded key with `SPARKLE_PUBLIC_ED_KEY=...`.

### 3. Build a DMG for the GitHub Release Page

If you want a user-friendly drag-install artifact, build the DMG too:

```bash
./scripts/release/build-release-dmg.sh
```

The DMG contains:

- `CorgiNotch.app`
- an `Applications` shortcut for drag-install

The script creates a disk image like:

```text
build/sparkle-release/CorgiNotch-2.2.4.dmg
```

Notes:

- The DMG build also performs a fresh archive build and `codesign --verify`.
- Sparkle still requires the `.zip` artifact; the DMG is for the human-facing GitHub release page.
- It is fine to attach both the `.zip` and `.dmg` to the same GitHub release as long as there is exactly one `CorgiNotch*.zip`.

### 4. Publish a GitHub Release

Create a GitHub release with:

- a tag matching the version you want to publish
- exactly one attached archive named `CorgiNotch*.zip`
- optionally a matching `CorgiNotch*.dmg`
- release notes in the GitHub release body

The release body is mirrored into a matching markdown file for Sparkle release notes.

### 5. Let the Workflow Publish the Appcast

When the release is published, `.github/workflows/publish-sparkle-appcast.yml`:

1. downloads the `CorgiNotch*.zip` asset from the GitHub release
   - it stages the new archive in a temporary directory first, then copies it into `gh-pages` so older archives do not break release detection
2. verifies the app bundle embeds the expected Sparkle public key and feed URL
3. decodes the Sparkle private key from repository secrets into a temporary file
   - it then passes that file to `generate_appcast --ed-key-file`, which is more reliable for CI than depending on Keychain access
4. copies the archive into the `gh-pages` update site
5. writes a matching markdown release notes file
6. runs `generate_appcast`
7. commits the updated appcast, archives, and delta files back to `gh-pages`

After that, the in-app **Check for Updates** action can discover the new release.

## Files Added for This Flow

- `scripts/release/build-release-archive.sh`
  - maintainer helper for building the release zip
- `scripts/release/build-release-dmg.sh`
  - maintainer helper for building a release DMG with the app bundle and an `Applications` shortcut
- `scripts/release/fetch-sparkle-tools.sh`
  - downloads the Sparkle distribution tools matching the repo’s pinned Sparkle version
- `.github/workflows/publish-sparkle-appcast.yml`
  - publishes Sparkle updates from GitHub Releases to GitHub Pages

## Troubleshooting

### Check for Updates still finds nothing

Verify all of the following:

- the release archive was built with the correct `SPARKLE_PUBLIC_ED_KEY`
- the release archive was attached to the published GitHub release
- the workflow succeeded
- `https://sssstf0rest.github.io/CorgiNotch/appcast.xml` is publicly reachable

### Workflow fails with missing Sparkle configuration

Make sure these exist:

- repository variable `SPARKLE_PUBLIC_ED_KEY`
- repository secret `SPARKLE_PRIVATE_ED_KEY_BASE64`

### Workflow says the archive feed URL is wrong

That means the release archive was built without the expected feed settings. Rebuild it using:

```bash
SPARKLE_APPCAST_URL="https://sssstf0rest.github.io/CorgiNotch/appcast.xml" \
./scripts/release/build-release-archive.sh
```
