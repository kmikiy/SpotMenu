import Cocoa
import WebKit
import AlamofireImage
import Alamofire

class ViewController: NSViewController {
    
    var lastArtworkUrl = ""
    
    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBOutlet weak var artworkImageView: NSImageView!

    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateInfo()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.updateInfo), name: InternalNotification.key, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let artist = Spotify.currentTrack.artist {
            artistLabel.stringValue = artist
        } else {
            artistLabel.stringValue = "Artist"
        }
        
        if let title = Spotify.currentTrack.title {
            titleLabel.stringValue = title
        } else {
            titleLabel.stringValue = "Title"
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
}
