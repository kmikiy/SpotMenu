# SpotMenu ![demo](https://github.com/kmikiy/SpotMenu/blob/master/SpotMenu/Assets.xcassets/AppIcon.appiconset/spotmenu%20(5)-1.png)
Spotify in your menu bar

## About

![demo](https://github.com/kmikiy/SpotMenu/blob/master/Demo/demo.gif)

SpotMenu is a combination of [TrayPlay](https://github.com/mborgerson/TrayPlay) 
and [Statusfy](https://github.com/paulyoung/Statusfy) written ~entirely~ _almost entirely_ in swift. 

![toast](https://github.com/kmikiy/SpotMenu/blob/master/Demo/toast.gif)

<kbd>control</kbd> + <kbd>command</kbd> + <kbd>m</kbd>

## Notes

- The default behavior is to only show the SpotMenu icon in the menubar. Right click → Preferences to customize.    
- The animated gif currently demonstrates the functionality of version 1.6   

## New Features in Version 1.6

+ Automatic updates added

+ German translation added (credits: [fabi94music](https://github.com/fabi94music))

+ Dutch translation added (credits: [rebdeb](https://github.com/rebdeg))

[List of all features](https://github.com/kmikiy/SpotMenu/blob/master/FEATURES.md)


## Easy Install

Download the zip file [version 1.6](https://github.com/kmikiy/SpotMenu/releases/download/v1.6/SpotMenu160.zip). Unarchive it. Run SpotMenu.app.
In case of unidentified developer follow these [steps](https://support.apple.com/kb/PH21769?locale=en_US)!

You can find all releases [here](https://github.com/kmikiy/SpotMenu/releases).

## Advanced Install

via [Homebrew Cask](https://caskroom.github.io)

```sh
brew cask install spotmenu
```

## How to Build

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
- Version 1.2 has been updated to swift 3.0 therefore Xcode 8 is required.
- In some cases it might be required to select the "Spotify" scheme and build it before selecting "SpotMenu".
- To fix "cannot find a team matching ..." error follow these [steps](https://github.com/kmikiy/SpotMenu/issues/54)

## Contributors

- [@danieltmbr](https://github.com/danieltmbr)
- [@maurojuniorr](https://github.com/maurojuniorr)
- [@Triloworld](https://github.com/Triloworld)
- [@fabi94music](https://github.com/fabi94music)
- [@rebdeb](https://github.com/rebdeg)
- Everyone who posted an [issue / pull request](https://github.com/kmikiy/SpotMenu/issues?utf8=✓&q=)

## Help

- Star and Fork
- Post any issues you find
- Post new feature requests
- Pull requests are welcome
- [![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NL4KDG65UYQB6) Help me get that new Tesla Model X 🚗 or a cup of coffee ☕️, anything helps 💸💰💵
