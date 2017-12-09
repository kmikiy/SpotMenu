import Cocoa
import WebKit
import MusicPlayer

final class PopOverViewController: NSViewController {
    
    // MARK: - Properties
    
    private var lastArtworkUrl = ""
    fileprivate var rightTimeIsDuration: Bool = true
    private var defaultImage: NSImage!
    private var musicPlayerManager: MusicPlayerManager!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak fileprivate var positionSlider: NSSlider!
    @IBOutlet weak private var artistLabel: NSTextField!
    @IBOutlet weak private var aLabel: NSTextField!
    @IBOutlet weak private var titleLabel: NSTextField!
    @IBOutlet weak private var playerStateButton: NSButton!
    @IBOutlet weak private var artworkImageView: NSImageView!
    @IBOutlet weak private var leftTime: NSTextField!
    @IBOutlet weak private var rightTime: NSTextField!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultImage = artworkImageView.image
        self.preferredContentSize = NSSize(width: 300, height: 300)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        updateInfo(track: musicPlayerManager.existMusicPlayer(with: .spotify)?.currentTrack)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.musicPlayerManager = MusicPlayerManager()
        self.musicPlayerManager.add(musicPlayer: MusicPlayerName.spotify)
        self.musicPlayerManager.add(musicPlayer: MusicPlayerName.iTunes)
        self.musicPlayerManager.delegate = self
    }
    
    // MARK: - Public methods
    

    func updateInfo(track: MusicTrack?) {
        if let track = track {
            if let artworkUrl = track.artworkUrl , artworkUrl != lastArtworkUrl {
                self.artworkImageView.downloadImage(url: URL(string: artworkUrl)!)
                lastArtworkUrl = artworkUrl
            }
            if track.artworkUrl == nil {
                artworkImageView.image = defaultImage
            }
            if let artwork = track.artwork {
                artworkImageView.image = artwork
            }
            
            if let artist = track.artist {
                artistLabel.stringValue = artist
                artistLabel.textColor = nil
                
            } else {
                artistLabel.stringValue = "Artist"
                artistLabel.textColor = NSColor.gray
            }
            
            titleLabel.stringValue = track.title
            titleLabel.textColor = nil
 
        } else {
            artistLabel.stringValue = "Artist"
            artistLabel.textColor = NSColor.gray
            
            titleLabel.stringValue = "Title"
            titleLabel.textColor = NSColor.gray
        }


//        let position = SpotifyAppleScript.currentTrack.positionPercentage
//        positionSlider.doubleValue = floor(position * 100)

//        updateTime()
    }
    
    // MARK: - Private methods
    
//    fileprivate func updateTime() {
//        let leftTimeTuple = secondsToHoursMinutesSeconds(seconds: SpotifyAppleScript.currentTrack.position)
//        leftTime.stringValue = getTimeString(tuple: leftTimeTuple)
//
//
//        switch rightTimeIsDuration {
//        case true:
//            let rightTimeTuple = secondsToHoursMinutesSeconds(seconds: SpotifyAppleScript.currentTrack.duration)
//            rightTime.stringValue = getTimeString(tuple: rightTimeTuple)
//        case false:
//            let rightTimeTuple = secondsToHoursMinutesSeconds(seconds: SpotifyAppleScript.currentTrack.duration - SpotifyAppleScript.currentTrack.position)
//            rightTime.stringValue = "-" + getTimeString(tuple: rightTimeTuple)
//        }
//
//    }

    private func updateButton(state: MusicPlaybackState) {
        switch state {
        case .paused:
            playerStateButton.title = "▶︎"
        case .playing:
            playerStateButton.title = "❚❚"
        default:
            playerStateButton.title = "▶︎"
        }
    }
    
    
    private func secondsToHoursMinutesSeconds (seconds : Double) -> (Int, Int, Int) {
        return (Int(seconds / 3600),
                Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60),
                Int((seconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy:
            60))))
    }
    
    private func getTimeString(tuple: (Int,Int,Int))-> String {
        return String(format: "%02d:%02d", tuple.1, tuple.2)
    }
}

// MARK: Actions

private extension PopOverViewController {
    
    @IBAction func goLeft(_ sender: NSButton) {
        self.musicPlayerManager.currentPlayer?.playPrevious()
    }
    
    @IBAction func goRight(_ sender: NSButton) {
        self.musicPlayerManager.currentPlayer?.playNext()
    }
    
    @IBAction func openSpotify(_ sender: Any) {
        self.musicPlayerManager.currentPlayer?.activate()
        //SpotifyAppleScript.activateSpotify()
    }
    
    @IBAction func positionSliderAction(_ sender: AnyObject) {
        self.musicPlayerManager.currentPlayer?.playerPosition = positionSlider.doubleValue/100.0
        //SpotifyAppleScript.currentTrack.positionPercentage = positionSlider.doubleValue/100.0
    }
    
    @IBAction func togglePlay(_ sender: AnyObject) {
        if let state = self.musicPlayerManager.currentPlayer?.playbackState {
            switch state {
            case .paused:
                self.musicPlayerManager.currentPlayer?.play()
            case .playing:
                self.musicPlayerManager.currentPlayer?.pause()
            default: break
            }
        }

    }
    
    @IBAction func toggleRightTime(_ sender: AnyObject) {
        rightTimeIsDuration = !rightTimeIsDuration
        //updateTime()
    }
}

extension PopOverViewController:  MusicPlayerManagerDelegate {
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, didChangeTrack track: MusicTrack, atPosition position: TimeInterval) {
        updateInfo(track: track)
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayer player: MusicPlayer, playbackStateChanged playbackState: MusicPlaybackState, atPosition position: TimeInterval) {
        updateInfo(track: player.currentTrack)
        updateButton(state: playbackState)
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidQuit player: MusicPlayer) {
        updateInfo(track: nil)
    }
    
    func manager(_ manager: MusicPlayerManager, trackingPlayerDidChange player: MusicPlayer) {
    }
    
}

// MARK: - NSImageView image download

extension NSImageView {
    
    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        
        getDataFromUrl(url: url) { (data, response, error)  in
            DispatchQueue.main.sync() { () -> Void in
                guard let data = data, error == nil else { return }
                self.image = NSImage(data: data)
            }
        }
    }
    
}
