//
//  PlayerTimer.swift
//  MusicPlayer
//
//  Created by Michael Row on 2017/9/18.
//

import Foundation

class PlayerTimer {
    
    class Key: Hashable {
        
        var hashValue: Int
        
        init<T: MusicPlayerEX>(_ player: T) {
            hashValue = player.hashValue
        }
        
        static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
    
    class Event {
        
        enum Kind {
            case Infinite
            case Period(Date)
        }
        
        typealias Action = (TimeInterval) -> Void
        
        private(set) var action: Action
        
        private(set) var kind: Kind
        
        private(set) var precision: TimeInterval
        
        init(kind: Kind, precision: TimeInterval, action: @escaping Action) {
            self.kind = kind
            self.precision = precision
            self.action = action
        }
    }
    
    static let shared = PlayerTimer()
    
    private var eventDict = [Key : Event]()
    
    private var timer: Timer?
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Register player event for periodically callback.
    ///
    /// - Warning: This method is based on Timer, so it's not a real-time mechanism. And the interval of
    ///   internal timer is equal or less than the precision needed. Note that if the main runloop is busy,
    ///   it would delay or just skip. The dispatcher would maintain strong reference to the player and closure
    ///   before you unregistering from it.
    func register<T: MusicPlayerEX>(_ player: T, event: Event) {
        timer?.invalidate()
        eventDict[player.key] = event
        fireTimer()
    }
    
    /// Unregister player for periodically callback
    ///
    /// - Parameter player: Selected player.
    func unregister<T: MusicPlayerEX>(_ player: T) {
        timer?.invalidate()
        eventDict.removeValue(forKey: player.key)
        fireTimer()
    }
    
    // MARK: - Private Methods
    
    private func fireTimer() {
        guard eventDict.count > 0 else { return }
        
        // get the min time interval
        let allEvents = eventDict.values
        var minPrecision = allEvents.first!.precision
        for event in allEvents {
            minPrecision = min(minPrecision, event.precision)
        }
        
        // start timer
        timer?.invalidate()
        timer = Timer(timeInterval: minPrecision, target: self, selector: #selector(notifyAllObservers(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    @objc private func notifyAllObservers(_ timer: Timer) {
        guard eventDict.count > 0 else {
            timer.invalidate()
            return
        }
        
        let precision = timer.timeInterval
        for key in eventDict.keys {
            
            guard let event = eventDict[key] else { continue }
            if case let .Period(endDate) = event.kind,
               endDate.timeIntervalSinceNow < 0
            {
                eventDict.removeValue(forKey: key)
                continue
            }
            
            event.action(precision)
        }
    }
}

fileprivate extension MusicPlayerEX {
    
    var key: PlayerTimer.Key {
        return PlayerTimer.Key(self)
    }
}
