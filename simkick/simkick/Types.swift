import Foundation


enum AppearanceMode: String, Equatable {
    case light
    case dark
    case unknown

    init(fromSimctl output: String) {
        let value = output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch value {
        case "light":
            self = .light
        case "dark":
			self = .dark
        default:
            self = .unknown
        }
    }

    var simctlArgument: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        case .unknown:
            return "unknown"
        }
    }
}
