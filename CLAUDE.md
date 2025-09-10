# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Simulator Sidekick (SimKick) is a macOS SwiftUI application that provides convenient controls for iOS Simulator operations. The app offers a compact interface for common simulator tasks like triggering Face ID authentication and toggling between light/dark appearance modes.

## Development Environment

### Prerequisites
- Xcode (with command line tools)
- macOS development environment
- iOS Simulator must be running ("booted") for commands to work

### Project Structure
- `simkick/` - Main Xcode project directory
  - `simkick.xcodeproj/` - Xcode project file
  - `simkick/` - Swift source files
    - `simkickApp.swift` - Main app entry point
    - `ContentView.swift` - Primary UI view
    - `SimulatorCommands.swift` - Core simulator control logic
    - `SimulatorState.swift` - App state management
    - `Types.swift` - Data types and enums
    - `Debouncer.swift` - Utility for delayed actions
- `export-options.plist` - Xcode archive export configuration

## Common Development Commands

### Building and Running
```bash
# Build the project (from simkick directory)
xcodebuild -project simkick.xcodeproj -scheme simkick -configuration Debug

# Build for release
xcodebuild -project simkick.xcodeproj -scheme simkick -configuration Release

# Archive for distribution (from simkick directory)
xcodebuild -project simkick.xcodeproj -scheme simkick -archivePath ./SimKick.xcarchive archive

# Export archive (from project root)
xcodebuild -exportArchive -archivePath ./simkick/SimKick.xcarchive -exportPath ./build -exportOptionsPlist export-options.plist
```

### Testing Simulator Commands
```bash
# Check current simulator appearance
xcrun simctl ui booted appearance

# Set simulator appearance
xcrun simctl ui booted appearance dark
xcrun simctl ui booted appearance light

# Trigger Face ID match
xcrun simctl spawn booted notifyutil -p com.apple.BiometricKit_Sim.fingerTouch.match

# List available simulators
xcrun simctl list devices
```

## Architecture

### Core Components
- **SimulatorCommands**: Static class containing all simulator control operations via `xcrun simctl`
- **SimulatorState**: ObservableObject managing UI state, particularly appearance mode
- **ContentView**: Main UI with Face ID trigger button and appearance toggle
- **Debouncer**: Utility class for preventing rapid successive API calls
- **AppearanceMode**: Enum for light/dark/unknown appearance states

### Key Features
- **Face ID Simulation**: Triggers biometric authentication match in simulator
- **Appearance Toggle**: Real-time switching between light and dark mode
- **Compact UI**: Fixed-size window (200x600) designed for sidebar usage
- **State Synchronization**: Debounced refresh to maintain UI consistency with simulator state

### Integration Points
The app integrates exclusively with iOS Simulator through `xcrun simctl` commands:
- UI appearance control via `simctl ui booted appearance`
- Biometric simulation via `simctl spawn booted notifyutil`
- All operations target the "booted" (currently running) simulator

### Future Expansion
Based on TODOs in ContentView.swift, planned enhancements include:
- GitHub Actions for automated builds
- Homebrew distribution
- Additional simulator tools beyond current Face ID and appearance controls