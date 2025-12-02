import AppKit
import Combine
import CoreGraphics

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private let tracker = SimulatorWindowTracker.shared
    private let settings = AttachmentSettings.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        setupTracking()
    }

    func registerMainWindow(_ window: NSWindow?) {
        guard let window = window else { return }
        mainWindow = window
        window.isMovableByWindowBackground = true
        updateWindowPosition()
        updateWindowVisibility()
    }

    private func setupTracking() {
        tracker.$simulatorWindow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateWindowPosition()
            }
            .store(in: &cancellables)

        tracker.$isSimulatorRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateWindowVisibility()
            }
            .store(in: &cancellables)

        settings.$side
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateWindowPosition()
            }
            .store(in: &cancellables)

        settings.$isEnabled
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateWindowPosition()
            }
            .store(in: &cancellables)
    }

    private func updateWindowVisibility() {
        guard let window = mainWindow else { return }

        if tracker.isSimulatorRunning {
            window.orderFront(nil)
            NSApp.activate(ignoringOtherApps: false)
        } else {
            window.orderOut(nil)
        }
    }

    private func updateWindowPosition() {
        guard let window = mainWindow,
              settings.isEnabled,
              let simWindow = tracker.simulatorWindow else {
            return
        }

        let windowSize = window.frame.size
        guard let position = tracker.calculateAttachedPosition(for: windowSize) else { return }

        let screen = NSScreen.screens.first(where: {
            $0.frame.intersects(simWindow.bounds)
        }) ?? NSScreen.main ?? NSScreen.screens.first!

        let flippedY = screen.frame.maxY - position.y - windowSize.height
        let newOrigin = CGPoint(x: position.x, y: flippedY)

        if window.frame.origin != newOrigin {
            window.setFrameOrigin(newOrigin)
        }
    }
}
