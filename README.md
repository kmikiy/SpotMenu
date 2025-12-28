# SpotMenu

**Spotify & Apple Music in your macOS menu bar**

A minimalist menu bar utility that displays your currently playing track with playback controls, keyboard shortcuts, and a beautiful native UI. Built with Swift and SwiftUI.

![Demo](https://github.com/user-attachments/assets/4b6b8e15-7180-44f1-abf7-796566a02fbb)

---

## Features

- **Menu Bar Integration** — View artist and song title directly in your menu bar
- **Playback Controls** — Hover overlay with play/pause, skip, and album art
- **Keyboard Shortcuts** — Global hotkeys for playback control
- **Track Liking** — Like/unlike tracks via Spotify Web API (Spotify only)
- **Compact View** — Toggle between full and compact display modes
- **Live Updates** — Automatically syncs with playback changes
- **Multi-Player Support** — Auto-detect or manually select Spotify / Apple Music
- **Fully Customizable** — Configure visuals, shortcuts, and behavior

---

## Installation

### Download

Get the latest release from [GitHub Releases](https://github.com/kmikiy/SpotMenu/releases/latest) and open `SpotMenu.app.zip`.

> **Note:** You may need to allow the app in **System Preferences → Privacy & Security** since it's not signed by an Apple developer. See [Apple's instructions](https://support.apple.com/kb/PH25088?locale=en_US) for details.

### Homebrew

```sh
brew install --cask spotmenu
```

### Build from Source

**Requirements:** macOS 26+, Xcode 16+

```bash
git clone https://github.com/kmikiy/SpotMenu.git
cd SpotMenu
open SpotMenu.xcodeproj
```

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
- **Apple Music**

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
- Like / Unlike / Toggle Like (Spotify only)

---

## Usage

| Action | Result |
|--------|--------|
| Left-click | Show/hide playback panel |
| Right-click | Open context menu |
| Hover on panel | Reveal playback controls |

---

## Support

If you find SpotMenu useful, consider [supporting development](https://paypal.me/kmikiy).

---

## License

MIT License. See [LICENSE](LICENSE) for details.
