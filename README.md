# SpotMenu ![demo](https://github.com/kmikiy/SpotMenu/blob/master/SpotMenu/Assets.xcassets/AppIcon.appiconset/spotmenu%20(5)-1.png)
Spotify in your menu bar

About
-----
![demo](https://github.com/kmikiy/SpotMenu/blob/master/demo.gif)

SpotMenu is a combination of [TrayPlay](https://github.com/mborgerson/TrayPlay) 
and [Statusfy](https://github.com/paulyoung/Statusfy) written entirely in swift. 

Note: The animated gif currently demonstrates the functionality of version 1.3

New Features in Version 1.3
---------------------------
+ New layout (with the help of [maurojuniorr](https://github.com/maurojuniorr))
+ Open Spotify UI from SpotMenu
+ Exit button moved to right click menu on menubar (credits: [Triloworld](https://github.com/Triloworld))
+ Issues added to right click (credits: [Triloworld](https://github.com/Triloworld))
+ Created a seperate pod for controlling Spotify on a mac. You can find the library [here](https://github.com/kmikiy/Spotify)

New Features in Version 1.2
---------------------------
+ Scrollbar now updates its position more frequently
+ Current track position is shown in text also (minutes:seconds)
+ The ability to toggle between the duration of the current track and the time remaining

New Features in Version 1.1
---------------------------
+ Added play/pause functionality
+ Added a scrollbar to jump to a position of the currently playing song
+ The menu bar now shows an icon if music is playing

Easy Install
------------

Download the zip file [version 1.3](https://github.com/kmikiy/SpotMenu/releases/download/v1.3/SpotMenu.zip). Unarchive it. Run SpotMenu.app.
In case of unidentified developer follow these [steps](https://mborgerson.com/trayplay)!

Older versions:   
[version 1.2](https://github.com/kmikiy/SpotMenu/releases/download/v1.2/SpotMenu_1_2.zip)   
[version 1.1](https://github.com/kmikiy/SpotMenu/releases/download/v1.2/SpotMenu_1_1.zip)   
... 

You can find all releases [here] (https://github.com/kmikiy/SpotMenu/releases).


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
