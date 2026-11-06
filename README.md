# SpotMenu

**Your music in your macOS menu bar**

A minimalist menu bar utility that displays your currently playing track with playback controls, keyboard shortcuts, and a beautiful native UI. Built with Swift and SwiftUI.

![Demo](https://github.com/user-attachments/assets/4b6b8e15-7180-44f1-abf7-796566a02fbb)

---

## Features

- **Menu Bar Integration** — View artist and song title directly in your menu bar
- **Playback Controls** — Hover overlay with play/pause, skip, and album art
- **Keyboard Shortcuts** — Global hotkeys for playback control
- **Track Liking** — Like/unlike tracks in Spotify, Spotifast, and Cider
- **Compact View** — Toggle between full and compact display modes
- **Live Updates** — Automatically syncs with playback changes
- **Multi-Player Support** — Auto-detect or select Spotifast / Spotify / Apple Music / Cider
- **Fully Customizable** — Configure visuals, shortcuts, and behavior

---

## Installation

### Download

Get the latest release from [GitHub Releases](https://github.com/kmikiy/SpotMenu/releases/latest) and open `SpotMenu.app.zip`.

The app is signed and notarized, and includes automatic updates via Sparkle.

### Homebrew

```sh
brew install --cask spotmenu
```

### Build from Source

**Requirements:** macOS 13+ (Ventura), Xcode 15+

```bash
git clone https://github.com/kmikiy/SpotMenu.git
cd SpotMenu
open SpotMenu.xcodeproj
```

For command-line builds, use the repository scripts:

```sh
./scripts/build.sh
./scripts/run.sh
./scripts/test.sh
./scripts/lint.sh
./scripts/format.sh --check
./scripts/validate.sh
```

The scripts use a local Apple Development certificate and detect its development team.
Set `SPOTMENU_SIGN_IDENTITY` and `SPOTMENU_DEVELOPMENT_TEAM` to select another signing identity.
The built app is at `build/Build/Products/Debug/SpotMenu.app` inside this checkout.
Set `SPOTMENU_BUILD_DIR` to use a different build directory.

### Continuous integration

The CI branch adds macOS build and unit-test checks, SwiftLint, Swift formatting, and shell syntax checks.
Builds use the runner's selected Xcode and ad-hoc signing on GitHub's `macos-26` runners, without a developer certificate or signing secrets.
The live Spotifast test remains an explicit local check because CI has no signed-in music player.

SwiftLint checks correctness rules in `.swiftlint.yml`. Swift's formatter owns layout, with four-space indentation and a 120-column limit.
Run `./scripts/format.sh --write` to apply formatting, or `./scripts/format.sh --check` to check without changes.
CI installs the pinned SwiftLint and actionlint versions through mise. Swift's formatter is included in Xcode.
Run `./scripts/test-ci.sh` to test with CI signing and locked Swift dependencies.
Use `./scripts/test-results.sh path/to/results.xcresult` to read an Xcode test summary.

`mise.toml` pins Node, actionlint, SwiftLint and OSV-Scanner for local and CI use.
Run `mise install node actionlint swiftlint osv-scanner` to install the tools. The mise shims select their pinned versions.
Run `./scripts/website.sh install` for a clean npm install, then `./scripts/website.sh build`.
Use `./scripts/website.sh preview` to preview the build at `http://localhost:4321/SpotMenu/`.
CI and Pages deployment use the same Node pin. Pull requests also build the website.

The dependency workflow runs on pushes, pull requests, manual dispatch, and daily at 00:00 UTC.
OSV-Scanner 2.7.0 checks SwiftPM and website/npm dependencies in separate jobs, including transitive dependencies.
Each job fails on known vulnerabilities and uploads its own JSON report, even when the other job fails.
The daily schedule starts after the workflow reaches the default branch.
For the same scan locally, run `./scripts/audit.sh` after installing the tools with mise.
Use `./scripts/audit.sh swift` or `./scripts/audit.sh website` to scan one ecosystem.

### Spotifast

Keep Spotifast 0.17.1 or later open, then select **Spotifast** under **Preferences → Music Player**.
SpotMenu displays the track, artist, artwork, playback progress, and liked state.
The playback controls, seek bar, and keyboard shortcuts also control Spotifast.
Liking uses your Spotifast sign-in and requires no separate Spotify login in SpotMenu.

**Automatic** selects a running player before an installed player.
The priority is Spotifast, Spotify, Apple Music, then Cider.

SpotMenu reads playback every two seconds through the documented Spotifast command-line interface.
An embedded XPC helper accesses the local control channel while SpotMenu keeps App Sandbox enabled.
The helper accepts only playback, seek, liking, and metadata commands. It does not run shell commands.
This helper requires distribution outside the Mac App Store.

If the connection fails, open Spotifast and select **Retry Connection** in SpotMenu preferences.
To test the installed Spotifast connection from the sandboxed app, load a track and run:

```sh
./scripts/test-spotifast.sh
```

This test reads playback and sends a command that preserves the current play or pause state.

---

## Spotify Setup

To enable track liking/unliking, you need to set up a Spotify Developer App.

1. Go to [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard)
2. Log in and click **Create an App**
3. Enter any name and description
4. In app settings, click **Edit Settings**
5. Under **Redirect URIs**, add:
   ```
   com.github.kmikiy.spotmenu://callback
   ```
6. Save and copy your **Client ID**
7. In SpotMenu, go to **Preferences → Music Player** and enable Track Liking
8. Paste your Client ID and complete the login flow

---

## Preferences

Access via right-click on the menu bar icon → **Preferences...**

### Music Player

Choose your music player:

- **Automatic** — Uses whichever player is active
- **Spotify**
- **Spotifast**
- **Apple Music**
- **Cider**

### Playback Appearance

Customize the player overlay:

- Hover Tint Color
- Foreground Color
- Blur Intensity
- Hover Tint Opacity

### Menu Bar

Configure display options:

- Show/hide artist and song title
- Show playing icon, liked icon, app icon
- Compact view mode
- Max width (40–300pt)

### Shortcuts

Set global hotkeys for:

- Play / Pause
- Next / Previous Track
- Like / Unlike / Toggle Like (supported players)

---

## Usage

| Action         | Result                   |
| -------------- | ------------------------ |
| Left-click     | Show/hide playback panel |
| Right-click    | Open context menu        |
| Hover on panel | Reveal playback controls |

---

## Support

If you find SpotMenu useful, consider [supporting development](https://paypal.me/kmikiy).

---

## License

MIT License. See [LICENSE](LICENSE) for details.
