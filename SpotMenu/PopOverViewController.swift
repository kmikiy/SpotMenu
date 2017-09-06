import Cocoa
import WebKit
import Spotify

final class PopOverViewController: NSViewController {
    
    // MARK: - Properties
    
    private var lastArtworkUrl = ""
    fileprivate var rightTimeIsDuration: Bool = true
    private var timer: Timer!
    private var defaultImage: NSImage!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak fileprivate var positionSlider: NSSlider!
    @IBOutlet weak private var artistLabel: NSTextField!
    @IBOutlet weak private var titleLabel: NSTextField!
    @IBOutlet weak private var playerStateButton: NSButton!
    @IBOutlet weak private var artworkImageView: NSImageView!
    @IBOutlet weak private var leftTime: NSTextField!
    @IBOutlet weak private var rightTime: NSTextField!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultImage = artworkImageView.image
        self.preferredContentSize = NSSize(width: 300, height: 298)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateInfo()
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(PopOverViewController.updateInfo),
                name: NSNotification.Name(rawValue: InternalNotification.key),
                object: nil)
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.8,
            target: self,
            selector: #selector(PopOverViewController.postUpdateNotification),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self)
        timer.invalidate()
    }
    
    // MARK: - Public methods
    
    func postUpdateNotification(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }

    func updateInfo() {
        if let artworkUrl = Spotify.currentTrack.artworkUrl , artworkUrl != lastArtworkUrl {
            self.artworkImageView.downloadImage(url: URL(string: artworkUrl)!)
            lastArtworkUrl = artworkUrl
        }
        if Spotify.currentTrack.artworkUrl == nil {
            artworkImageView.image = defaultImage
        }
        
        if let artist = Spotify.currentTrack.albumArtist {
            artistLabel.stringValue = artist
            artistLabel.textColor = nil
            
        } else {
            artistLabel.stringValue = "Artist"
            artistLabel.textColor = NSColor.gray
        }
        
        if let title = Spotify.currentTrack.title {
            titleLabel.stringValue = title
            titleLabel.textColor = nil
        } else {
            titleLabel.stringValue = "Title"
            titleLabel.textColor = NSColor.gray
        }
        
        let position = Spotify.currentTrack.positionPercentage
        positionSlider.doubleValue = floor(position * 100)
        
        updateTime()
        updateButton()
    }
    
    // MARK: - Private methods
    
    fileprivate func updateTime() {
        let leftTimeTuple = secondsToHoursMinutesSeconds(seconds: Spotify.currentTrack.position)
        leftTime.stringValue = getTimeString(tuple: leftTimeTuple)
        
        
        switch rightTimeIsDuration {
        case true:
            let rightTimeTuple = secondsToHoursMinutesSeconds(seconds: Spotify.currentTrack.duration)
            rightTime.stringValue = getTimeString(tuple: rightTimeTuple)
        case false:
            let rightTimeTuple = secondsToHoursMinutesSeconds(seconds: Spotify.currentTrack.duration - Spotify.currentTrack.position)
            rightTime.stringValue = "-" + getTimeString(tuple: rightTimeTuple)
        }
        
    }

    private func updateButton() {
        updateButton(Spotify.playerState)
    }
    
    private func updateButton(_ state: PlayerState){
        switch state {
        case .paused:
            playerStateButton.title = "▶︎"
        case .playing:
            playerStateButton.title = "❚❚"
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
        Spotify.playPrevious()
    }
    
    @IBAction func goRight(_ sender: NSButton) {
        Spotify.playNext()
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
    @IBAction func openSpotify(_ sender: Any) {
        Spotify.activateSpotify()
    }
    
    @IBAction func positionSliderAction(_ sender: AnyObject) {
        Spotify.currentTrack.positionPercentage = positionSlider.doubleValue/100.0
    }
    
    @IBAction func togglePlay(_ sender: AnyObject) {
        switch Spotify.playerState {
        case .paused:
            Spotify.playerState = .playing
        case .playing:
            Spotify.playerState = .paused
        }
    }
    
    @IBAction func toggleRightTime(_ sender: AnyObject) {
        rightTimeIsDuration = !rightTimeIsDuration
        updateTime()
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
