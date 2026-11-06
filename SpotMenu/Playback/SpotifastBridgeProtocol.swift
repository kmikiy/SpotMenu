import Foundation

@objc(SpotifastBridgeProtocol)
protocol SpotifastBridgeProtocol {
    func execute(_ arguments: [String], reply: @escaping (String?, String?) -> Void)
}

enum SpotifastBridgeCommand {
    static let serviceName = "com.github.kmikiy.SpotMenu.SpotifastBridge"

    static func isAllowed(_ arguments: [String]) -> Bool {
        if arguments == ["now-playing", "--raw"] { return true }
        if arguments.count == 1 {
            return ["play-pause", "play", "pause", "next", "previous", "like"]
                .contains(arguments[0])
        }
        return arguments.count == 2 && arguments[0] == "seek-to"
            && UInt32(arguments[1]) != nil
    }
}
