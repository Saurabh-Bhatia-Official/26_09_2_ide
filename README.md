<p align="center">
  <img src="assets/images/mingo_logo.png" alt="Mingo IDE Logo" width="220" />
</p>

# Mingo IDE — Cross-Platform Developer Environment

[![Multi-Platform Build & Release](https://github.com/Saurabh-Bhatia-Official/26_09_2_ide/actions/workflows/build.yml/badge.svg)](https://github.com/Saurabh-Bhatia-Official/26_09_2_ide/actions/workflows/build.yml)

Mingo IDE is a modern, high-performance, and intelligent cross-platform developer environment built with Flutter, providing a full-featured workspace across **Windows, macOS, Linux, Android, and iOS**.

---

## 🚀 Key Features

> 📖 For an in-depth, comprehensive breakdown of all capabilities, see [features.md](features.md).

- **Activity Bar & Workspace Sidebar**:
  - File Explorer with folder tree, file creation, renaming, and deletion
  - Full-text search and replace across the workspace
  - Git / Source Control with staged/unstaged diff tracking, branch management, and commit workflows
  - Run & Debug inspector with breakpoint controls
  - Extension marketplace with categorized add-ons and instant install
  - Remote development manager (SSH, WSL, Dev Containers, Cloud Workspaces)
  - Settings panel with customizable themes, typography, editor font sizes, minimap, and line numbers
- **Editor Area**:
  - Tabbed multi-file editor with dirty state tracking and keyboard navigation
  - Syntax highlighting for 12+ languages (Dart, Rust, TypeScript, JavaScript, Python, C++, Go, HTML, CSS, JSON, Markdown, YAML)
  - Split editor support and customizable minimap
  - Side-by-side Diff editor for Git comparison
  - Interactive Welcome view with quick actions and keyboard shortcuts
- **Bottom Panel**:
  - Interactive integrated terminal emulator with command execution and history
  - Diagnostics / Problems view with file and line navigation
  - Output streams (Flutter, Build, Tasks)
  - Debug console with runtime evaluation
  - Forwarded ports inspector and preview modal
- **AI Copilot & Assistant**:
  - Integrated AI assistant panel for contextual code generation, explanation, and automated refactoring
- **Cross-Platform & Mobile Optimization**:
  - Adaptive responsive layout for desktop, tablet, and mobile breakpoints
  - Mobile bottom navigation, slide-over drawer, and quick coding keyboard toolbar
  - Command Palette (`Ctrl+P` / `Cmd+P`) for rapid navigation and action execution

---

## 📦 Multi-Platform Build & Packaging

The project includes an enterprise-grade automated CI/CD pipeline via GitHub Actions (`.github/workflows/build.yml`) that builds, packages, and verifies artifacts for all supported platforms upon push to `main`:

| Platform | Format | Build Command | Output Artifact |
|---|---|---|---|
| **Windows** | `.exe` (Installer), `.zip` (Portable) | `flutter build windows --release` | `Mingo-IDE-Setup-v1.0.0.exe`, `Mingo-IDE-Windows-Portable.zip` |
| **macOS** | `.dmg` (Disk Image), `.zip` (App bundle) | `flutter build macos --release` | `Mingo-IDE-macOS.dmg`, `Mingo-IDE-macOS.zip` |
| **Linux** | `.deb` (Debian Package), `.tar.gz` | `flutter build linux --release` | `Mingo-IDE-v1.0.0-Linux-x64.deb`, `Mingo-IDE-v1.0.0-Linux-x64.tar.gz` |
| **Android** | `.apk` (Release Package) | `flutter build apk --release` | `Mingo-IDE-Android.apk` |
| **iOS** | `.ipa` (Payload Package), `.zip` | `flutter build ios --release --no-codesign` | `Mingo-IDE-iOS-unsigned.ipa`, `Mingo-IDE-iOS-app.zip` |

---

## 🛠️ CI/CD Pipeline Specifications

- **Branch Protection & Trigger Rules**: Configured to trigger **only when code is pushed to the `main` branch**. Automatically ignores documentation updates to conserve CI resources.
- **Automated Verification**: Runs full static analysis (`flutter analyze`) and automated widget & provider test suites (`flutter test`) before producing release packages.
- **Checksum Verification**: Generates `SHA256SUMS.txt` cryptographic digests for all compiled release binaries.
- **GitHub Release Integration**: Automatically publishes an official release tagged with the commit SHA and attaches compiled platform packages.

---

## 💻 Getting Started Locally

### Prerequisites

- Flutter SDK (`>= 3.12.2`)
- Dart SDK (`>= 3.12.2`)
- Platform-specific build tools:
  - **Windows**: Visual Studio 2022/2026 with Desktop development with C++
  - **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `liblzma-dev`
  - **macOS / iOS**: Xcode and Command Line Tools
  - **Android**: Android SDK & Java 17 (JDK)

### Development Commands

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Static Analysis**:
   ```bash
   flutter analyze
   ```

3. **Run Automated Test Suite**:
   ```bash
   flutter test
   ```

4. **Launch Application Locally**:
   ```bash
   # Desktop
   flutter run -d windows    # On Windows
   flutter run -d macos      # On macOS
   flutter run -d linux      # On Linux

   # Mobile & Web
   flutter run -d android    # On Android device / emulator
   flutter run -d ios        # On iOS simulator
   flutter run -d chrome     # On Web
   ```

---

## 📄 License

This project is licensed under the MIT License.
