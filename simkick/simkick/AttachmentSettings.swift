import SwiftUI
import Combine

enum AttachmentSide: String, CaseIterable {
    case left
    case right
}

class AttachmentSettings: ObservableObject {
    static let shared = AttachmentSettings()

    @Published var side: AttachmentSide {
        didSet { UserDefaults.standard.set(side.rawValue, forKey: "attachmentSide") }
    }

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "attachmentEnabled") }
    }

    @Published var gap: Double {
        didSet { UserDefaults.standard.set(gap, forKey: "attachmentGap") }
    }

    private init() {
        let sideString = UserDefaults.standard.string(forKey: "attachmentSide") ?? "right"
        self.side = AttachmentSide(rawValue: sideString) ?? .right
        self.isEnabled = UserDefaults.standard.object(forKey: "attachmentEnabled") as? Bool ?? true
        self.gap = UserDefaults.standard.double(forKey: "attachmentGap")
    }
}
