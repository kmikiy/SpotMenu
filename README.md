# SpotMenu ![Icon](https://github.com/user-attachments/assets/704ed30e-3995-4bf0-b33d-07e0291bc027)

Minimalist Now Playing for macOS menu bar — works with **Spotify** 🎵 and **Apple Music** 🍎

![demo](https://github.com/user-attachments/assets/4b6b8e15-7180-44f1-abf7-796566a02fbb)

## ✨ Overview

SpotMenu is a macOS menu bar utility that shows your currently playing track with support for compact views, keyboard shortcuts, and rich visual controls. Built in Swift and SwiftUI, it supports **Spotify** and **Apple Music** through AppleScript integration.

## 🔧 Features

- 🖥️ **Menu Bar Integration** — View artist and song title directly in your menu bar.
- 🎛️ **Compact/Custom Views** — Toggle between full and compact visual modes.
- 🖼️ **Playback Controls** — Overlay with play/pause/skip buttons and album art.
- ⌨️ **Keyboard Shortcuts** — Global hotkeys to control playback.
- ⚙️ **User Preferences** — Configure visuals, shortcuts, and music player via Preferences window.
- 🪄 **Live Updates** — Automatically syncs with playback changes.
- 🔁 **Multi-Player Support** — Automatically detect or manually select between Spotify and Apple Music.
- 🍎 macOS native look and feel with SwiftUI.

## 📦 Installation

### Easy Install

Download the latest [release](https://github.com/kmikiy/SpotMenu/releases) and open `SpotMenu.app.zip`.

> ⚠️ You might need to allow the app in **System Preferences → Security & Privacy** as it's not signed by an Apple developer. Click here for detailed [instructions](https://support.apple.com/kb/PH25088?locale=en_US)!

## Advanced Install

via [Homebrew Cask](https://formulae.brew.sh/cask/)

```sh
brew install --cask spotmenu
```

### Build from Source

#### Requirements

- macOS 11+
- Xcode 14+

#### Steps

```bash
git clone https://github.com/kmikiy/SpotMenu.git
cd SpotMenu
open SpotMenu.xcodeproj
```

## 🎨 Preferences

Accessible via right-clicking the menu bar icon → Preferences…

![preferences](https://github.com/kmikiy/SpotMenu/raw/refs/heads/master/assets/media/preferences.mov)

### Visuals Tab

Toggle:

- Display Artist
- Display Song Title
- Show Playing Icon
- Display App Icon
- Compact View Mode

Adjust:

- Max Width of the Status Item (80–300 pt)

### Shortcuts Tab

Assign keys for:

- Play / Pause
- Next Track
- Previous Track

### Player Tab

Choose which music player SpotMenu should control:

- Automatic — Detects and uses whichever player is active.
- Spotify
- Apple Music

## 🧠 Usage Tips

- Menu Toggle: Left-click to show/hide the playback panel.
- Right Click: Access Preferences and Quit.
- Playback Panel: Hover to reveal play/pause, skip, and album art.
