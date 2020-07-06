# SpotMenu ![demo](https://github.com/kmikiy/SpotMenu/blob/master/SpotMenu/Assets.xcassets/AppIcon.appiconset/spotmenu%20(5)-1.png?raw=true)
Spotify and iTunes in your menu bar

# macOS MOJAVE BETA disclaimer

SpotMenu is currently **NOT** (entirely) compatible with Spotify on macOS MOJAVE BETA. SpotMenu will cause Spotify to crash. 
You can read more about how to fix it [here](https://github.com/kmikiy/SpotMenu/issues/126).


## Sponsors

SpotMenu is being sponsored by the following tool; please help to support us by taking a look and signing up to a free trial.

<a href="https://tracking.gitads.io/?repo=SpotMenu">
  <img alt="Sponsor banner" src="https://images.gitads.io/SpotMenu" />
</a>

## About

![demo](https://github.com/kmikiy/SpotMenu/blob/master/Demo/demo.gif?raw=true)

SpotMenu is a combination of [TrayPlay](https://github.com/mborgerson/TrayPlay) 
and [Statusfy](https://github.com/paulyoung/Statusfy) written ~entirely~ _almost entirely_ in swift. 

Toast: <kbd>control</kbd> + <kbd>shift</kbd> + <kbd>m</kbd>

## Notes

- The default behavior is to show the SpotMenu icon, Artist and Track title in the menubar. Right click → Preferences to customize.    
- The animated gif currently demonstrates the functionality of version 1.7

## Donate

- [![Paypal](https://github.com/kmikiy/SpotMenu/blob/master/Donation/pp.png?raw=true)](http://paypal.me/kmikiy) [paypal.me/kmikiy](https://paypal.me/kmikiy) Help me get that new Tesla Model X 🚗 or a cup of coffee ☕️, anything helps 💸💰💵
- Or help me become a cryptocurrency  millionaire 🔐   
    - ![Ƀitcoin](https://github.com/kmikiy/SpotMenu/blob/master/Donation/btc.png?raw=true) 1Cc79kaUUWZ2fD7iFAnr5i89vb2j6JunvA
    - ![Ethereum](https://github.com/kmikiy/SpotMenu/blob/master/Donation/eth.png?raw=true) 0xFA06Af34fd45c0213fc909F22cA7241BBD94076f
    - ![Łitecoin](https://github.com/kmikiy/SpotMenu/blob/master/Donation/ltc.png?raw=true) LS3ibFQWd2xz1ByZajrzS3Y787LgRwHYVE
    
## New Features in Version 1.9

+ Layout updated
+ Fixed light album cover issue on MacOS Mojave
+ Cross fade animation on track change
+ Scrolling text (credits: [@NicholasBellucci](https://github.com/NicholasBellucci))
+ Added Fabric

[List of all features](https://github.com/kmikiy/SpotMenu/blob/master/FEATURES.md)


## Easy Install

Download the zip file [version 1.9](https://github.com/kmikiy/SpotMenu/releases/download/v1.9/SpotMenu190.zip). Unarchive it. Run SpotMenu.app.
I do not have an  developer account to sign the app with therefore you will most likely receive a warning that the app is from an unidentified developer. To open the app follow these [steps](https://support.apple.com/kb/PH25088?locale=en_US)!

You can find all releases [here](https://github.com/kmikiy/SpotMenu/releases).

## Advanced Install

via [Homebrew Cask](https://caskroom.github.io)

```sh
brew cask install spotmenu
```

## How to Build

First, you'll need Xcode 9. You can download this at the [Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).
Second, you'll need [CocoaPods](https://guides.cocoapods.org/using/getting-started.html). 

Now, use [Git](http://git-scm.com/) to clone the repository.

```sh
git clone https://github.com/kmikiy/SpotMenu.git
cd SpotMenu
pod install
```

Finally, open up the SpotMenu.xcworkspace. Set the "Scheme" to build the "SpotMenu" target for "My Mac". Then Product > Run (or the shortcut ⌘R).

Note: 
- Version 1.7 has been updated to swift 4.0 therefore Xcode 9 is required.
- In some cases it might be required to select the "MusicPlayer" scheme and build it before selecting "SpotMenu".
- To fix "cannot find a team matching ..." error follow these [steps](https://github.com/kmikiy/SpotMenu/issues/54)

## Contributors

Many thanks to [@danieltmbr](https://github.com/danieltmbr), [@NicholasBellucci](https://github.com/NicholasBellucci), [@KamranMackey](https://github.com/KamranMackey), [@maurojuniorr](https://github.com/maurojuniorr), [@Triloworld](https://github.com/Triloworld), [@fabi94music](https://github.com/fabi94music), [@rebdeb](https://github.com/rebdeg), [@bcubic](https://github.com/bcubic), [@clinis](https://github.com/clinis), [@Lynx901](https://github.com/Lynx901) [@BatyaMedic](https://github.com/BatyaMedic) and everyone who posted an [issue](https://github.com/kmikiy/SpotMenu/issues?utf8=✓&q=) / [pull request](https://github.com/kmikiy/SpotMenu/pulls?utf8=✓&q=)

## Help

- Star and Fork
- Post any issues you find (please check existing issues before posting!)
- Post new feature requests
- Pull requests are welcome

## Localisation

If you would like SpotMenu in your native language please translate this [file](https://github.com/kmikiy/SpotMenu/blob/master/SpotMenu/Localizable/en.lproj/Localizable.strings) and either create a Pull Request, send it to me via email or post it to this [issue](https://github.com/kmikiy/SpotMenu/issues/44). I will add it to the next release of SpotMenu. Bear in mind that community will have to keep these language files up-to-date ☝🏻.

[![HitCount](http://hits.dwyl.io/kmikiy/SpotMenu.svg)](http://hits.dwyl.io/kmikiy/SpotMenu)

## Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/kmikiy/SpotMenu/graphs/contributors"><img src="https://opencollective.com/SpotMenu/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Become a financial contributor and help us sustain our community. [[Contribute](https://opencollective.com/SpotMenu/contribute)]

#### Individuals

<a href="https://opencollective.com/SpotMenu"><img src="https://opencollective.com/SpotMenu/individuals.svg?width=890"></a>

#### Organizations

Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/SpotMenu/contribute)]

<a href="https://opencollective.com/SpotMenu/organization/0/website"><img src="https://opencollective.com/SpotMenu/organization/0/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/1/website"><img src="https://opencollective.com/SpotMenu/organization/1/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/2/website"><img src="https://opencollective.com/SpotMenu/organization/2/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/3/website"><img src="https://opencollective.com/SpotMenu/organization/3/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/4/website"><img src="https://opencollective.com/SpotMenu/organization/4/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/5/website"><img src="https://opencollective.com/SpotMenu/organization/5/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/6/website"><img src="https://opencollective.com/SpotMenu/organization/6/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/7/website"><img src="https://opencollective.com/SpotMenu/organization/7/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/8/website"><img src="https://opencollective.com/SpotMenu/organization/8/avatar.svg"></a>
<a href="https://opencollective.com/SpotMenu/organization/9/website"><img src="https://opencollective.com/SpotMenu/organization/9/avatar.svg"></a>
