import Foundation

/// Keeps displayed progress moving between Cider updates and rejects the old
/// track's time when its track-change event arrives before the HTTP snapshot.
struct CiderProgressClock {
    private(set) var trackID: String?
    private var anchor = 0.0
    private var sampledAt = Date.distantPast
    private var transitionAt: Date?
    private var previousTrackID: String?
    private var duration = 1.0
    private var playing = false

    mutating func reset() {
        self = CiderProgressClock()
    }

    mutating func markTrackChange(at now: Date = Date()) {
        transitionAt = now
        previousTrackID = trackID
        anchor = 0
        sampledAt = now
    }

    func shouldWaitForNewTrack(_ incomingID: String?, at now: Date = Date()) -> Bool {
        guard let transitionAt, now.timeIntervalSince(transitionAt) < 2 else { return false }
        return incomingID == previousTrackID
    }

    mutating func acceptSnapshot(trackID incomingID: String?, elapsed: Double,
                                 duration: Double, playing: Bool, at now: Date = Date()) -> Double {
        let changed = incomingID != trackID
        let hadTrack = trackID != nil
        trackID = incomingID
        self.duration = max(1, duration)
        self.playing = playing
        if incomingID == nil {
            anchor = 0
            sampledAt = now
            transitionAt = nil
            return 0
        }

        if changed && hadTrack && transitionAt != nil {
            anchor = 0
            sampledAt = now
            previousTrackID = nil
            return 0
        }
        _ = acceptTime(elapsed, at: now)
        return current(at: now)
    }

    mutating func acceptTime(_ elapsed: Double, playing: Bool? = nil,
                             at now: Date = Date()) -> Double {
        if let playing { self.playing = playing }
        guard elapsed.isFinite, elapsed >= 0 else { return current(at: now) }
        if let transitionAt {
            let age = max(0, now.timeIntervalSince(transitionAt))
            // Cider can briefly pair the new item with the previous item's time.
            if age < 10 && elapsed > age + 5 { return current(at: now) }
            if age >= 10 { self.transitionAt = nil }
        }
        anchor = min(elapsed, duration)
        sampledAt = now
        return current(at: now)
    }

    func current(at now: Date = Date()) -> Double {
        guard trackID != nil else { return 0 }
        let advance = playing ? max(0, now.timeIntervalSince(sampledAt)) : 0
        return min(duration, max(0, anchor + advance))
    }
}
