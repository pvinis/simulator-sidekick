import SwiftUI

class SimulatorState: ObservableObject {
    @Published var appearance: AppearanceMode = .unknown

    var isDarkMode: Bool {
        get { appearance == .dark }
        set { appearance = newValue ? .dark : .light }
    }
}
