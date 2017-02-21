import Cocoa
import WebKit
import Spotify

class ViewController: NSViewController {
    
    @IBOutlet weak var positionSlider: NSSlider!
    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var playerStateButton: NSButton!
    @IBOutlet weak var artworkImageView: NSImageView!
    @IBOutlet weak var leftTime: NSTextField!
    @IBOutlet weak var rightTime: NSTextField!
    
    var lastArtworkUrl = ""
    var rightTimeIsDuration: Bool = true
    var timer: Timer!
    var defaultImage: NSImage!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateInfo), name: NSNotification.Name(rawValue: InternalNotification.key), object: nil)
        
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(ViewController.postUpdateNotification), userInfo: nil, repeats: true)
    }
    
    func postUpdateNotification(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultImage = artworkImageView.image
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self)
        timer.invalidate()
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
    
    func updateButton() {
        updateButton(Spotify.playerState)
    }
    
    func updateButton(_ state: PlayerState){
        switch state {
        case .paused:
            playerStateButton.title = "▶︎"
        case .playing:
            playerStateButton.title = "❚❚"
        }
    }
    
    func updateTime() {
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

extension ViewController {
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

extension NSImageView {
    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        
//        Swift.print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            DispatchQueue.main.sync() { () -> Void in
                guard let data = data, error == nil else { return }
//                Swift.print(response?.suggestedFilename ?? url.lastPathComponent)
//                Swift.print("Download Finished")
                self.image = NSImage(data: data)
            }
        }
    }
    
}
