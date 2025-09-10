import Foundation

class SimulatorCommands {
    
    static func triggerFaceIDMatch() {
        let task = Process()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "spawn", "booted", "notifyutil", "-p", "com.apple.BiometricKit_Sim.fingerTouch.match"]
        
        do {
            try task.run()
            print("Face ID match triggered successfully")
        } catch {
            print("Failed to trigger Face ID match: \(error)")
            // TODO: add error tracking
        }
    }
    
    static func getCurrentAppearance() -> AppearanceMode {
        let task = Process()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "ui", "booted", "appearance"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "unknown"
            let mode = AppearanceMode(fromSimctl: output)
            print("Current appearance: \(mode.rawValue)")
            return mode
        } catch {
            print("Failed to get current appearance: \(error)")
            return .unknown
        }
    }
    
    static func setAppearance(_ mode: AppearanceMode) {
        guard mode == .light || mode == .dark else { return }
        let task = Process()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "ui", "booted", "appearance", mode.simctlArgument]
        
        do {
            try task.run()
            print("Appearance set to: \(mode.rawValue)")
        } catch {
            print("Failed to set appearance: \(error)")
        }
    }

    static func toggleAppearance() {
        let current = getCurrentAppearance()
        let next: AppearanceMode = (current == .dark) ? .light : .dark
        setAppearance(next)
    }
}
