# SpotMenu ![demo](https://github.com/kmikiy/SpotMenu/blob/master/SpotMenu/Assets.xcassets/AppIcon.appiconset/spotmenu%20(5)-1.png)
Spotify in your menu bar

## About

![demo](https://github.com/kmikiy/SpotMenu/blob/master/demo.gif)

SpotMenu is a combination of [TrayPlay](https://github.com/mborgerson/TrayPlay) 
and [Statusfy](https://github.com/paulyoung/Statusfy) written entirely in swift. 

## Notes

+ The default behavior is to only show the SpotMenu icon in the menubar. Right click -> Preferences to customize.    
+ The animated gif currently demonstrates the functionality of version 1.4   

## New Features in Version 1.4.2

+ Customization
  - Open at login

## All features

### Added in Version 1.4.1

+ Customization
  - Fix popover to the right
  
### Added in Version 1.4

+ Customization
  - Show/hide Artist
  - Show/hide Title
  - Show/hide SpotMenu icon
  - Show/hide Playing symbol

### Added in Version 1.3

+ New layout (with the help of [maurojuniorr](https://github.com/maurojuniorr))
+ Open Spotify UI from SpotMenu
+ Exit button moved to right click menu on menubar (credits: [Triloworld](https://github.com/Triloworld))
+ Issues added to right click (credits: [Triloworld](https://github.com/Triloworld))
+ Created a seperate pod for controlling Spotify on a mac. You can find the library [here](https://github.com/kmikiy/Spotify)
+ Display album artist instead of current track artist

### Added in Version 1.2

+ Scrollbar now updates its position more frequently
+ Current track position is shown in text also (minutes:seconds)
+ The ability to toggle between the duration of the current track and the time remaining

### Added in Version 1.1

+ Added play/pause functionality
+ Added a scrollbar to jump to a position of the currently playing song
+ The menu bar now shows an icon if music is playing

### Added in Version 1.0

+ Show playing music in menubar
+ Popover to show album artwork
+ Skip to next/previous song

Easy Install
------------

Download the zip file [version 1.4.2](https://github.com/kmikiy/SpotMenu/releases/download/v1.4.2/SpotMenu.zip). Unarchive it. Run SpotMenu.app.
In case of unidentified developer follow these [steps](https://mborgerson.com/trayplay)!

You can find all releases [here](https://github.com/kmikiy/SpotMenu/releases).


How to Build
------------

First, you'll need Xcode 8. You can download this at the [Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).
Second, you'll need [CocoaPods](https://guides.cocoapods.org/using/getting-started.html). 

Now, use [Git](http://git-scm.com/) to clone the repository.

```sh
git clone https://github.com/kmikiy/SpotMenu.git
cd SpotMenu
pod install
```

Finally, open up the SpotMenu.xcworkspace. Set the "Scheme" to build the "SpotMenu" target for "My Mac". Then Product > Run (or the shortcut ⌘R).

Note: 
+ Version 1.2 has been updated to swift 3.0 therefore Xcode 8 is required.
+ In some cases it might be required to select the "Spotify" scheme and build it before selecting "SpotMenu".

Help
----
+ Star and Fork
+ Post any issues you find
+ Post new feature requests
+ [![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NL4KDG65UYQB6) Help me get that new Tesla Model X 🚗 or a cup of coffee ☕️, anything helps 💸💰💵
