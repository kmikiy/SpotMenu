import Cocoa
import WebKit
import AlamofireImage
import Alamofire
import Spotify

class ViewController: NSViewController {
    
    var lastArtworkUrl = ""
    
    @IBOutlet weak var positionSlider: NSSlider!

    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var playerStateButton: NSButton!
    
    @IBOutlet weak var artworkImageView: NSImageView!

    var defaultImage: NSImage!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateInfo()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.updateInfo), name: InternalNotification.key, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultImage = artworkImageView.image
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func updateInfo() {
        if let artworkUrl = Spotify.currentTrack.artworkUrl where artworkUrl != lastArtworkUrl {
            Alamofire.request(.GET, artworkUrl)
                .responseImage { response in
//                    debugPrint(response)
//                    print(response.request)
//                    print(response.response)
//                    debugPrint(response.result)
                    
                    if let image = response.result.value {
//                        print("image downloaded: \(image)")
                        self.artworkImageView.image = image
                    }
            }
            lastArtworkUrl = artworkUrl
        }
        if Spotify.currentTrack.artworkUrl == nil {
            artworkImageView.image = defaultImage
        }
        
        if let artist = Spotify.currentTrack.artist {
            artistLabel.stringValue = artist
            artistLabel.textColor = nil
            
        } else {
            artistLabel.stringValue = "Artist"
            artistLabel.textColor = NSColor.grayColor()
        }
        
        if let title = Spotify.currentTrack.title {
            titleLabel.stringValue = title
            titleLabel.textColor = nil
        } else {
            titleLabel.stringValue = "Title"
            titleLabel.textColor = NSColor.grayColor()
        }
        
        let position = Spotify.currentTrack.positionPercentage
        positionSlider.doubleValue = position * 100
        
        updateButton()
    }
    
    func updateButton() {
        updateButton(Spotify.playerState)
        
    }
    
    func updateButton(state: PlayerState){
        switch state {
        case .paused:
            playerStateButton.title = "▶︎"
        case .playing:
            playerStateButton.title = "🁢🁢"
        }
        
    }
    
}

// MARK: Actions

extension ViewController {
    @IBAction func goLeft(sender: NSButton) {
        Spotify.playPrevious()
    }
    
    @IBAction func goRight(sender: NSButton) {
        Spotify.playNext()
    }
    
    @IBAction func quit(sender: NSButton) {
        NSApplication.sharedApplication().terminate(sender)
    }
    
    @IBAction func positionSliderAction(sender: AnyObject) {
        Spotify.currentTrack.positionPercentage = positionSlider.doubleValue/100.0
    }
    
    @IBAction func togglePlay(sender: AnyObject) {
        //playerStateButton.alphaValue = 0
        switch Spotify.playerState {
        case .paused:
            Spotify.playerState = .playing
            //updateButton(.paused)
        case .playing:
            Spotify.playerState = .paused
            //updateButton(.playing)
        }
    }
}
