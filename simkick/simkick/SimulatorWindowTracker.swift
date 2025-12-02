import AppKit
import CoreGraphics
import Combine

struct TrackedWindow {
    let windowID: CGWindowID
    let bounds: CGRect
    let title: String
    let ownerPID: pid_t
}

class SimulatorWindowTracker: ObservableObject {
    static let shared = SimulatorWindowTracker()

    @Published var simulatorWindow: TrackedWindow?
    @Published var isSimulatorRunning: Bool = false

    private var pollingTimer: Timer?
    private var workspaceObservers: [NSObjectProtocol] = []

    private init() {
        setupWorkspaceObservers()
        checkSimulatorRunning()
    }

    deinit {
        stopTracking()
        workspaceObservers.forEach { NSWorkspace.shared.notificationCenter.removeObserver($0) }
    }

    private func setupWorkspaceObservers() {
        let launchObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.bundleIdentifier == "com.apple.iphonesimulator" {
                self?.isSimulatorRunning = true
                self?.startTracking()
            }
        }

        let terminateObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.bundleIdentifier == "com.apple.iphonesimulator" {
                self?.isSimulatorRunning = false
                self?.simulatorWindow = nil
                self?.stopTracking()
            }
        }

        workspaceObservers = [launchObserver, terminateObserver]
    }

    private func checkSimulatorRunning() {
        isSimulatorRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == "com.apple.iphonesimulator"
        }
        if isSimulatorRunning {
            startTracking()
        }
    }

    func startTracking() {
        guard pollingTimer == nil else { return }
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.updateSimulatorWindow()
        }
        updateSimulatorWindow()
    }

    func stopTracking() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func updateSimulatorWindow() {
        let windows = getSimulatorWindows()
        if let window = windows.first {
            if simulatorWindow?.bounds != window.bounds || simulatorWindow?.windowID != window.windowID {
                simulatorWindow = window
            }
        } else {
            simulatorWindow = nil
        }
    }

    private func getSimulatorWindows() -> [TrackedWindow] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        return windowList.compactMap { dict -> TrackedWindow? in
            guard let ownerName = dict[kCGWindowOwnerName as String] as? String,
                  ownerName == "Simulator",
                  let layer = dict[kCGWindowLayer as String] as? Int,
                  layer == 0,
                  let windowID = dict[kCGWindowNumber as String] as? CGWindowID,
                  let boundsDict = dict[kCGWindowBounds as String] as? [String: Any],
                  let x = (boundsDict["X"] as? NSNumber)?.doubleValue,
                  let y = (boundsDict["Y"] as? NSNumber)?.doubleValue,
                  let width = (boundsDict["Width"] as? NSNumber)?.doubleValue,
                  let height = (boundsDict["Height"] as? NSNumber)?.doubleValue else {
                return nil
            }

            let bounds = CGRect(x: x, y: y, width: width, height: height)

            let title = dict[kCGWindowName as String] as? String ?? ""
            let ownerPID = dict[kCGWindowOwnerPID as String] as? pid_t ?? 0

            if title.isEmpty || title == "Simulator" {
                return nil
            }

            return TrackedWindow(
                windowID: windowID,
                bounds: bounds,
                title: title,
                ownerPID: ownerPID
            )
        }
    }

    func calculateAttachedPosition(for windowSize: CGSize) -> CGPoint? {
        guard let simWindow = simulatorWindow else { return nil }
        let settings = AttachmentSettings.shared
        let gap = CGFloat(settings.gap)

        var point: CGPoint
        switch settings.side {
        case .left:
            point = CGPoint(
                x: simWindow.bounds.minX - windowSize.width - gap,
                y: simWindow.bounds.minY
            )
        case .right:
            point = CGPoint(
                x: simWindow.bounds.maxX + gap,
                y: simWindow.bounds.minY
            )
        }

        if let screen = NSScreen.screens.first(where: { $0.frame.intersects(simWindow.bounds) }) {
            let screenFrame = screen.visibleFrame
            if point.x < screenFrame.minX {
                point.x = simWindow.bounds.maxX + gap
            } else if point.x + windowSize.width > screenFrame.maxX {
                point.x = simWindow.bounds.minX - windowSize.width - gap
            }
        }

        return point
    }
}
