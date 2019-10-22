import Cocoa
import MusicPlayer
import WebKit

final class PopOverViewController: NSViewController {

    // MARK: - Properties

    private var lastArtworkUrl = ""
    fileprivate var rightTimeIsDuration: Bool = true
    private var defaultImage: NSImage!
    private var musicPlayerManager: MusicPlayerManager!
    private var position: Double = 0
    private var duration: Double = 0
    private var isPlaying: Bool = false
    private var timer: Timer!
    private let spotMenuIcon = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
    private let spotMenuIconItunes = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImageItunes"))

    // MARK: - IBOutlets

    @IBOutlet fileprivate var positionSlider: NSSlider!
    @IBOutlet private var artistLabel: NSTextField!
    @IBOutlet private var aLabel: NSTextField!
    @IBOutlet private var titleLabel: NSTextField!
    @IBOutlet private var playerStateButton: NSButton!
    @IBOutlet private var artworkImageView: NSImageView!
    @IBOutlet private var leftTime: NSTextField!
    @IBOutlet private var rightTime: NSTextField!
    @IBOutlet private var musicPlayerButton: NSButton!

    public enum Constants {
         static let width: CGFloat = 300
         static let height: CGFloat = 300
     }
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultImage = artworkImageView.image
        preferredContentSize = NSSize(
            width: Constants.width,
            height: Constants.height
        )
        
        if #available(OSX 10.13, *) {
            view.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        setUpMusicPlayerManager()
        musicPlayerManager.delegate = self

        let lastMusicPlayerName = MusicPlayerName(rawValue: UserPreferences.lastMusicPlayer)!
        let lastMusicPlayer = musicPlayerManager.existMusicPlayer(with: lastMusicPlayerName)
        musicPlayerManager.currentPlayer = lastMusicPlayer
        let track = lastMusicPlayer?.currentTrack
        updateInfo(track: track)

        let state = lastMusicPlayer?.playbackState
        updateButton(state: state)

        if let state = state {
            isPlaying = state == .playing
        }
        if let track = track {
            duration = track.duration
        }
        if let position = lastMusicPlayer?.playerPosition {
            self.position = position
        }

        updatePlayerPosition()
        updateTime()
        updateMusicPlayerIcon(musicPlayerName: lastMusicPlayerName)

        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updatePlayerPosition),
            userInfo: nil,
            repeats: true)
    }

    override func viewDidDisappear() {
        timer.invalidate()
        musicPlayerManager.delegate = nil
    }

    // MARK: - Public methods

    func setUpMusicPlayerManager() {
        if musicPlayerManager == nil {
            musicPlayerManager = MusicPlayerManager()
            musicPlayerManager.add(musicPlayer: MusicPlayerName.spotify)
            musicPlayerManager.add(musicPlayer: MusicPlayerName.iTunes)
        }
    }

    // MARK: - Private methods

    @objc private func updatePlayerPosition() {
        if isPlaying {
            position = position + 1
            updateTime()
        }
        positionSlider.doubleValue = floor(position / duration * 100)
    }

    private func updateInfo(track: MusicTrack?) {
        if let track = track {
            if let artworkUrl = track.artworkUrl, artworkUrl != lastArtworkUrl {
                if let url = URL(string: artworkUrl) {
                    artworkImageView.downloadImage(url: url)
                    lastArtworkUrl = artworkUrl
                }
            }
            if track.artworkUrl == nil {
                artworkImageView.image = defaultImage
            }
            if let artwork = track.artwork {
                artworkImageView.image = artwork
            }

            if let artist = track.artist {
                artistLabel.stringValue = artist

            } else {
                artistLabel.stringValue = NSLocalizedString("Artist", comment: "")
            }

            titleLabel.stringValue = track.title
            titleLabel.textColor = nil

        } else {
            artistLabel.stringValue = NSLocalizedString("Artist", comment: "")
            titleLabel.stringValue = NSLocalizedString("Title", comment: "")
        }

        updateTime()
    }

    fileprivate func updateTime() {
        let leftTimeTuple = secondsToHoursMinutesSeconds(seconds: position)
        leftTime.stringValue = getTimeString(tuple: leftTimeTuple)

        switch rightTimeIsDuration {
        case true:
            let rightTimeTuple = secondsToHoursMinutesSeconds(seconds: duration)
            rightTime.stringValue = getTimeString(tuple: rightTimeTuple)
        case false:
            let rightTimeTuple = secondsToHoursMinutesSeconds(seconds: duration - position)
            rightTime.stringValue = "-" + getTimeString(tuple: rightTimeTuple)
        }
    }

    private func updateButton(state: MusicPlaybackState?) {
        if let state = state {
            switch state {
            case .paused:
                playerStateButton.title = "▶︎"
            case .playing, .fastForwarding, .rewinding, .reposition:
                playerStateButton.title = "❚❚"
            default:
                playerStateButton.title = "▶︎"
            }
        } else {
            playerStateButton.title = "▶︎"
        }
    }

    private func secondsToHoursMinutesSeconds(seconds: Double) -> (Int, Int, Int) {
        return (Int(seconds / 3600),
                Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60),
                Int((seconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy:
                        60))))
    }

    private func getTimeString(tuple: (Int, Int, Int)) -> String {
        return String(format: "%02d:%02d", tuple.1, tuple.2)
    }

    private func updateMusicPlayerIcon(musicPlayerName: MusicPlayerName?) {
        if musicPlayerName == MusicPlayerName.iTunes {
            musicPlayerButton.image = spotMenuIconItunes
        } else {
            musicPlayerButton.image = spotMenuIcon
        }
    }
}

// MARK: Actions

private extension PopOverViewController {

    @IBAction func goLeft(_: NSButton) {
        musicPlayerManager.currentPlayer?.playPrevious()
    }

    @IBAction func goRight(_: NSButton) {
        musicPlayerManager.currentPlayer?.playNext()
    }

    @IBAction func openSpotify(_: Any) {
        musicPlayerManager.currentPlayer?.activate()
    }

    @IBAction func positionSliderAction(_: AnyObject) {
        position = (positionSlider.doubleValue / 100.0) * duration
        musicPlayerManager.currentPlayer?.playerPosition = position
    }

    @IBAction func togglePlay(_: AnyObject) {
        if let state = self.musicPlayerManager.currentPlayer?.playbackState {
            switch state {
            case .playing, .fastForwarding, .rewinding, .reposition:
                musicPlayerManager.currentPlayer?.pause()
            default:
                musicPlayerManager.currentPlayer?.play()
            }
        } else {
            musicPlayerManager.currentPlayer?.play()
        }
    }

    @IBAction func toggleRightTime(_: AnyObject) {
        rightTimeIsDuration = !rightTimeIsDuration
        updateTime()
    }
}

extension PopOverViewController: MusicPlayerManagerDelegate {
    func manager(_: MusicPlayerManager, trackingPlayer player: MusicPlayer, didChangeTrack track: MusicTrack, atPosition position: TimeInterval) {
        duration = track.duration
        self.position = position
        updateInfo(track: track)
        updateMusicPlayerIcon(musicPlayerName: player.name)
    }

    func manager(_: MusicPlayerManager, trackingPlayer player: MusicPlayer, playbackStateChanged playbackState: MusicPlaybackState, atPosition position: TimeInterval) {
        self.position = position
        switch playbackState {
        case .playing, .fastForwarding, .rewinding, .reposition:
            isPlaying = true
        default:
            isPlaying = false
        }
        updateInfo(track: player.currentTrack)
        updateButton(state: playbackState)
        updateMusicPlayerIcon(musicPlayerName: player.name)
    }

    func manager(_: MusicPlayerManager, trackingPlayerDidQuit _: MusicPlayer) {
        updateInfo(track: nil)
    }

    func manager(_: MusicPlayerManager, trackingPlayerDidChange player: MusicPlayer) {
        updateMusicPlayerIcon(musicPlayerName: player.name)
    }
}

// MARK: - NSImageView image download

extension NSImageView {

    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            data, response, error in
            completion(data, response, error)
        }.resume()
    }

    func downloadImage(url: URL) {

        getDataFromUrl(url: url) { data, _, error in
            DispatchQueue.main.sync() { () -> Void in
                guard let data = data, error == nil else { return }
                
                if #available(OSX 10.12, *) {
                    CATransaction.begin()
                    let fadeAnim = CABasicAnimation(keyPath: "opacity")
                    fadeAnim.fromValue = 1
                    fadeAnim.toValue = 0.2
                    fadeAnim.duration = 0.2
                    CATransaction.setCompletionBlock({
                        self.image = NSImage(data: data)
                        let fadeAnim = CABasicAnimation(keyPath: "opacity")
                        fadeAnim.fromValue = 0.2
                        fadeAnim.toValue = 1
                        fadeAnim.duration = 0.4
                        self.layer?.add(fadeAnim, forKey: "opacity")
                    })
                    self.layer?.add(fadeAnim, forKey: "opacity")
                    CATransaction.commit()
                } else {
                    self.image = NSImage(data: data)
                }
                
            }
        }
    }
}
