# Repository Guidelines

## Project Structure & Module Organization
- App code: `simkick/simkick/` (SwiftUI views, state, utilities). Example files: `ContentView.swift`, `SimulatorCommands.swift`.
- Xcode project: `simkick/simkick.xcodeproj/`.
- Assets: `simkick/simkick/Assets.xcassets/`.
- Build artifacts: `simkick/build/` (created by CI/local builds).
- Release archive: `SimKick.zip` at repo root (from CI/`just archive`).

## Build, Test, and Development Commands
- `just build` — Release build with `xcodebuild` using scheme `simkick` and derived data in `simkick/build`.
- `just clean` — Remove `simkick/build` and `SimKick.zip`.
- `just archive` — Build then zip app to `SimKick.zip`.
- Direct build example: `cd simkick && xcodebuild -project simkick.xcodeproj -scheme simkick -configuration Release clean build`.
- CI: `.github/workflows/archive.yml` builds on macOS and uploads `SimKick.zip`.

## Coding Style & Naming Conventions
- Language: Swift 5+ and SwiftUI.
- Indentation: 4 spaces; no tabs.
- Types: UpperCamelCase (`SimulatorState`), methods/properties: lowerCamelCase (`triggerFaceIDMatch`).
- One primary type per file; file names match the main type (e.g., `Debouncer.swift`).
- Keep `SimulatorCommands` as the boundary for `xcrun simctl` calls.

## Testing Guidelines
- Framework: XCTest (add a test target when introducing tests).
- Place tests under `simkick/` in a `simkickTests` target; name files `*Tests.swift` and methods `test…`.
- Run (once tests exist): `xcodebuild test -project simkick/simkick.xcodeproj -scheme simkick -destination 'platform=macOS'`.
- Prefer fast unit tests for logic (e.g., `AppearanceMode`, `Debouncer`).

## Commit & Pull Request Guidelines
- Commits: imperative mood, concise subject (<72 chars), descriptive body explaining why and how.
- Reference issues (`Fixes #123`) when applicable.
- Branch names: `feat/...`, `fix/...`, `chore/...`.
- PRs: include a clear description, testing steps, linked issue(s), and screenshots/GIFs for UI changes.

## Security & Configuration Tips
- Requires macOS with Xcode and Command Line Tools; CI uses `macos-latest`.
- Code signing uses automatic settings (see `export-options.plist`).
- When adding simulator features, prefer `simctl` via `SimulatorCommands` and handle errors gracefully.
