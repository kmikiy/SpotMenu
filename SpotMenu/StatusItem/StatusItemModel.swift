import Foundation

class StatusItemModel: ObservableObject {
    @Published var topText: String = ""
    @Published var bottomText: String = ""
    @Published var isPlaying: Bool = false

    var showAppIconOnly: Bool {
        return topText.isEmpty && bottomText.isEmpty && !isPlaying
    }

    var isTextEmpty: Bool {
        return topText.isEmpty && bottomText.isEmpty
    }
}
