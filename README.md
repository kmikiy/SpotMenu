# SpotMenu ![Icon](https://github.com/user-attachments/assets/704ed30e-3995-4bf0-b33d-07e0291bc027)

Minimalist Now Playing for macOS menu bar — works with **Spotify** 🎵

![demo](https://github.com/user-attachments/assets/4b6b8e15-7180-44f1-abf7-796566a02fbb)

---

## ✨ Overview

SpotMenu is a macOS menu bar utility that shows your currently playing Spotify track with support for compact views, keyboard shortcuts, and rich visual controls. Built primarily in Swift and SwiftUI, it provides seamless integration with Spotify using AppleScript.

---

## 🔧 Features

- 🖥️ **Menu Bar Integration** — View artist and song title directly in your menu bar.
- 🎛️ **Compact/Custom Views** — Toggle between full and compact visual modes.
- 🖼️ **Playback Controls** — Overlay with play/pause/skip buttons and album art.
- ⌨️ **Keyboard Shortcuts** — Global hotkeys to control playback.
- ⚙️ **User Preferences** — Easily configure visuals and shortcuts via Preferences window.
- 🪄 **Live Updates** — Automatically syncs with Spotify playback changes.
- 🍎 macOS native look and feel with SwiftUI.

---

## 📦 Installation

### Easy Install

Download the latest [release](https://github.com/kmikiy/SpotMenu/releases) and open `SpotMenu.app`.

> ⚠️ You might need to allow the app in **System Preferences → Security & Privacy** as it's not signed by an Apple developer.

---

### Advanced: Build from Source

#### Requirements

- macOS 11+
- Xcode 14+

#### Steps

```bash
git clone https://github.com/kmikiy/SpotMenu.git
cd SpotMenu
open SpotMenu.xcodeproj
```

---

## 🎨 Preferences

Accessible via right-clicking the menu bar icon → Preferences…

![preferences](https://github.com/user-attachments/assets/bfa41f55-5eb2-4a89-998b-f4726927dd2c)

### Visuals Tab

Toggle:

- Display Artist
- Display Song Title
- Show Playing Icon
- Compact View Mode

### Shortcuts Tab

Assign keys for:

- Play / Pause
- Next Track
- Previous Track

---

## 🧠 Usage Tips

- Menu Toggle: Left-click to show/hide the playback panel.
- Right Click: Access Preferences and Quit.
- Playback Panel: Hover to reveal play/pause, skip, and album art.
