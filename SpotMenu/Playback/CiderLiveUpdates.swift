import Foundation

enum CiderLiveUpdates: Equatable {
    case checking, active, unavailable

    static func shouldMarkUnavailable(isPlaying: Bool, lastEventAt: Date?,
                                      checkingSince: Date, at now: Date) -> Bool {
        isPlaying && now.timeIntervalSince(lastEventAt ?? checkingSince) >= 6
    }

    func snapshotInterval(connected: Bool) -> TimeInterval {
        guard connected else { return 15 }
        return self == .active ? 30 : 2
    }
}
