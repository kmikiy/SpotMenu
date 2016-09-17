# SpotMenu ![demo](https://github.com/kmikiy/SpotMenu/blob/master/SpotMenu/Assets.xcassets/AppIcon.appiconset/spotmenu%20(5)-1.png)
Spotify in your menu bar

About
-----
![demo](https://github.com/kmikiy/SpotMenu/blob/master/demo.gif)

SpotMenu is a combination of [TrayPlay](https://github.com/mborgerson/TrayPlay) 
and [Statusfy](https://github.com/paulyoung/Statusfy) written entirely in swift. 

Note: The animated gif currently demonstrates the functionality of version 1.0

New Features in Version 1.1
---------------------
+ Added play/pause functionality
+ Added a scrollbar to jump to a position of the currently playing song
+ The menu bar now shows an icon if music is playing

Easy Install
------------

Download the zip file [version 1.0](https://github.com/kmikiy/SpotMenu/raw/master/SpotMenu.zip) or [version 1.1](https://github.com/kmikiy/SpotMenu/raw/master/SpotMenu_1_1.zip). Unarchive it. Run SpotMenu.app.
In case of unidentified developer follow these [steps](https://mborgerson.com/trayplay)!

How to Build
------------

First, you'll need Xcode. You can download this at the [Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).
Second, you'll need [CocoaPods](https://guides.cocoapods.org/using/getting-started.html). 

Now, use [Git](http://git-scm.com/) to clone the repository and clone the submodules.

    git clone https://github.com/kmikiy/SpotMenu.git
    cd SpotMenu
    pod install

Finally, open up the SpotMenu.xcworkspace. Set the "Scheme" to build the SpotMenu target for "My Mac". Then Product > Run (or the shortcut ⌘R).
