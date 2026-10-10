# ⚡ Mingo IDE — Feature Specification & Capabilities

<p align="center">
  <img src="assets/images/mingo_logo.png" alt="Mingo IDE Logo" width="220" />
</p>

Mingo IDE is a modern, high-performance, and intelligent cross-platform developer environment built with Flutter and Dart. Designed to run natively across **Desktop (Windows, macOS, Linux)**, **Mobile (Android, iOS)**, and the **Web**, it provides an end-to-end coding workflow with zero compromise.

---

## 📑 Table of Contents

1. [Workspace Navigation & Primary Sidebar](#1-workspace-navigation--primary-sidebar)
2. [Editor Area & Code Workspace](#2-editor-area--code-workspace)
3. [Integrated Bottom Panel](#3-integrated-bottom-panel)
4. [AI Copilot & Coding Assistant](#4-ai-copilot--coding-assistant)
5. [Command Palette & Keyboard Shortcuts](#5-command-palette--keyboard-shortcuts)
6. [Cross-Platform & Adaptive UX](#6-cross-platform--adaptive-ux)
7. [Security & Workspace Trust](#7-security--workspace-trust)
8. [Theming, Typography & Aesthetics](#8-theming-typography--aesthetics)
9. [Integrated Modals & Tools](#9-integrated-modals--tools)
10. [Automated CI/CD & Multi-Platform Packaging](#10-automated-cicd--multi-platform-packaging)

---

## 1. Workspace Navigation & Primary Sidebar

The Activity Bar and collapsible Primary Sidebar (`Ctrl+B` / `Cmd+B`) provide instant access to essential developer workflows:

### 📁 File Explorer
- **Folder Tree & Hierarchy**: Interactive directory tree with expand/collapse animations.
- **File Management**: Create new files, create folders, rename, and delete directly from the UI or context menus.
- **Native File Picker**: Open any local directory or individual file on desktop and mobile storage.
- **Extension-Aware File Icons**: Dynamic icons matching file extensions (`.dart`, `.rs`, `.ts`, `.js`, `.py`, `.json`, `.md`, `.yaml`, `.html`, `.css`, etc.).
- **Dirty State Indicators**: Real-time visual tracking of unsaved changes per file.

### 🔍 Global Search & Replace
- **Full-Text Workspace Search**: Instant search across all open and project files (`Ctrl+Shift+F`).
- **Match Filtering**: Case sensitivity toggle, whole word matching, and regex querying.
- **Match Navigation**: File-by-file grouped results with match counts and one-click navigation to precise line numbers.
- **Workspace Replace**: Single-match or batch replacement across files.

### 🌿 Source Control (Git)
- **Visual Git Status**: Clear separation between **Staged Changes** and **Unstaged Changes** (`Ctrl+Shift+G`).
- **Stage / Unstage Controls**: Individual file staging or one-click stage/unstage all.
- **Commit Management**: Commit message input field with commit execution and verification.
- **Branch Tracking**: Active branch indicator with seamless branch switching.
- **Side-by-Side Diff Triggering**: Instant jump to visual Git Diff editor from changed file entries.

### 🐞 Run & Debug Inspector
- **Debug Session Management**: Start debugging (`F5`), run without debugging (`Ctrl+F5`), pause, restart, and stop.
- **Breakpoint Manager**: Toggle and inspect active breakpoints with file and line coordinate mapping.
- **Call Stack & Threads**: Visual call stack frame inspection.
- **Variable Watches**: Local and global variable watch tree.

### 🧩 Extension Marketplace
- **Marketplace Browsing**: Discover popular developer extensions and tool integrations (`Ctrl+Shift+X`).
- **Categorized Extensions**: Linters (ESLint), Formatters (Prettier), Language Servers (Rust Analyzer, Python IntelliCode), and Git extensions (GitLens).
- **One-Click Installation**: Install, configure, and disable extensions with real-time UI status updates.

### ☁️ Remote Development Manager
- **Multi-Environment Support**: Connect to **SSH Remote Hosts**, **WSL (Windows Subsystem for Linux)**, **Docker Dev Containers**, and **Cloud Workspaces**.
- **Container Runtime Monitoring**: Real-time connection status indicators, IP tracking, and port mapping.

### 🧪 Test Runner & Suite Explorer
- **Test Discovery**: Automatic scanning and presentation of test suites.
- **Granular Execution**: Run all tests or trigger individual test cases.
- **Live Status Metrics**: Color-coded test outcomes (Passed, Failed, Running, Skipped) with execution timestamps.

### ⚙️ Preferences & Settings
- **Theme Switcher**: Live switching between built-in dark, light, and corporate themes.
- **Typography & Editor Font**: Configurable font families (JetBrains Mono, Fira Code, Inter, Gray) and font sizes.
- **Editor Customization**: Toggle line numbers, minimap, soft wrapping, and indentation spacing.
- **Auto-Save Settings**: Configurable auto-save timers and behavior.

---

## 2. Editor Area & Code Workspace

### 📑 Tabbed Multi-Document System
- **Multi-Tab Workflow**: Open and switch between unlimited concurrent documents.
- **Dirty Tracking**: Distinct dot indicator (`•`) on modified tabs; auto-saving and manual save shortcuts (`Ctrl+S` / `Cmd+S`).
- **Tab Actions**: Close tab (`Ctrl+W`), close other tabs, close saved tabs, or close all.

### 🎨 Real-Time Syntax Highlighting
- **Multi-Language Parser**: Native lexical tokenizing supporting 12+ programming languages:
  - **Dart / Flutter**
  - **Rust**
  - **TypeScript & JavaScript**
  - **Python**
  - **C & C++**
  - **Go**
  - **HTML & CSS**
  - **JSON, YAML, & Markdown**
- **Token Classification**: Distinct highlight colors for keywords, strings, types, functions, comments, numbers, and operators based on the active theme.

### 🪟 Side-by-Side Diff Editor
- **Visual Git Diffing**: Two-column comparison view for unstaged and staged file modifications.
- **Synchronized Scrolling**: Paired scrolling across left (original) and right (modified) panes.
- **Gutter Annotations**: Color-coded line additions (green) and line deletions (red) with clean line number offsets.

### 🚀 Interactive Welcome View
- **Quick Start Actions**: Direct buttons to Open Folder, Open File, or New Document.
- **Recent Workspace History**: List of recent workspaces for instant access.
- **Keyboard Shortcuts Cheat Sheet**: Visual guide to keybindings.
- **Brand Presentation**: High-resolution glowing Mingo IDE logo and edition details.

---

## 3. Integrated Bottom Panel

Toggleable panel (`Ctrl+\``) providing essential console and diagnostic streams:

### 💻 Integrated Terminal Emulator
- **Native Real Shell Execution**: Spawns real system shells via `Process.start`:
  - **Windows**: PowerShell, Command Prompt, Git Bash
  - **macOS / Linux**: Bash, Zsh, Sh
  - **Web**: Virtual interactive shell session (`mingo-sh`)
- **Multi-Session Tabs**: Create, rename, switch, and terminate multiple terminal sessions.
- **Terminal History & ANSI Styling**: Command input buffer, history recall, color-coded status output.
- **Project Root Directory Awareness**: Spawns directly into the open workspace folder.

### ⚠️ Diagnostics & Problems View
- **Real-Time Issue Tracking**: Aggregated list of errors, warnings, and informational diagnostics across the workspace.
- **Direct Navigation**: Clicking any diagnostic line immediately opens the target file and jumps to the exact line/column.
- **Filter by Severity**: Quickly filter issues by Error, Warning, or Info levels.

### 📄 Output Streams
- **Channel Switching**: Dropdown selector for output streams:
  - *Mingo Language Engine*
  - *Mingo Engine Daemon*
  - *Build Tasks*
  - *Extension Logs*
- **Clear & Copy Controls**: One-click output clearing and clipboard export.

### 🪲 Debug Console
- **REPL Interface**: Interactive prompt for evaluating expressions during active debugging sessions.
- **Log Streaming**: Detailed runtime output with timestamping and source tags.

### 🌐 Forwarded Ports Inspector
- **Port Mapping**: Track and manage forwarded ports (e.g., `3000`, `8080`, `5173`).
- **Forward New Port**: Add ports with local address configuration and protocol labeling.
- **Integrated Preview Trigger**: Direct button to launch the in-app Web Preview modal.

---

## 4. AI Copilot & Coding Assistant

Built-in AI Assistant (`Ctrl+Shift+A` or Activity Bar):

- **Context-Aware Chat**: Interactive conversational interface aware of the active file, cursor position, and workspace context.
- **Model Switching**: Switch between AI backends:
  - *Mingo-1 Pro (Cloud)*
  - *Mingo-Code Ultra*
  - *Local Llama 3 8B (On-Device GPU)*
- **Prompt Action Chips**: Instant single-click shortcut chips:
  - 💡 *Explain Code*
  - 🧪 *Generate Tests*
  - 🛠️ *Refactor & Optimize*
  - 🐞 *Find & Fix Bugs*
- **Markdown & Code Output**: Rich rendered responses with syntax-highlighted code blocks and copy-to-clipboard buttons.

---

## 5. Command Palette & Keyboard Shortcuts

Press `Ctrl+P` (Windows/Linux) or `Cmd+P` (macOS) to summon the Command Palette:

- **Fuzzy Search**: Search files, commands, editor actions, settings, and views with fuzzy filtering.
- **Visual Shortcut Badges**: Displays associated keybindings for every command.
- **Instant Execution**: Trigger any IDE feature without lifting your fingers from the keyboard.

---

## 6. Cross-Platform & Adaptive UX

Mingo IDE dynamically adapts its layout and interaction paradigm based on the target platform and viewport size:

| Breakpoint / Form Factor | Adaptive Behavior |
|---|---|
| **Desktop (≥ 1050px)** | Full frameless title bar with native window controls, desktop menu bar (File, Edit, View, Run, Terminal, Help), drag-to-move window header, persistent activity bar, dual-column layout, and bottom panel. |
| **Tablet (640px – 1049px)** | Compact title bar, icon-only activity bar, collapsible sidebar with slide gestures, responsive modal scaling. |
| **Mobile (< 640px)** | Bottom navigation bar, slide-over navigation drawer, compact headers, and **Mobile Coding Keyboard Toolbar** featuring quick programming keys (`{`, `}`, `(`, `)`, `;`, `=>`, `"`, `'`, `Tab`). |

---

## 7. Security & Workspace Trust

- **Workspace Trust Modal (PRD §86)**: Visual prompt when opening untrusted repositories.
- **Execution Permission Gating**: Restricts automatic task execution, terminal scripts, and unsigned extensions until the user explicitly grants workspace trust.
- **Trust Configuration**: Easily toggle trust status per workspace in the Settings panel.

---

## 8. Theming, Typography & Aesthetics

- **Curated Themes**:
  - **Mingo Dark (Default)**: Sleek, high-contrast dark theme optimized for long coding sessions.
  - **Gray**: Clean neutral gray modern aesthetic.
  - **Mingo Light Modern**: Crisp, high-readability daylight theme.
  - **White Corporate**: Polished corporate light style.
  - **Legacy Dark**: Classic IDE palette.
- **Typography Engine**: Google Fonts integration with developer fonts (JetBrains Mono, Fira Code, Inter).
- **Glassmorphic Accents**: Subtle glows, translucent panels, and smooth micro-animations.

---

## 9. Integrated Modals & Tools

- **About Mingo IDE Dialog**: Accessible from the Title Bar logo or Help menu; displays official branding, build commit, release date, and target architecture.
- **Integrated Web Preview Modal**: Mini embedded browser dialog with URL bar, refresh button, external browser launcher, and live web preview.
- **Workspace Trust Configuration Modal**: Interactive security dialog explaining sandbox boundaries and trust levels.

---

## 10. Automated CI/CD & Multi-Platform Packaging

Enterprise-grade GitHub Actions pipeline (`.github/workflows/build.yml`) that builds, validates, and packages release binaries on push to `main`:

| Target Platform | Package Format | Binary Artifact |
|---|---|---|
| **Windows** | Inno Setup `.exe` Installer & Portable `.zip` | `Mingo-IDE-Setup-v1.0.0.exe`, `Mingo-IDE-Windows-Portable.zip` |
| **macOS** | Apple Disk Image (`.dmg`) & App Bundle `.zip` | `Mingo-IDE-macOS.dmg`, `Mingo-IDE-macOS.zip` |
| **Linux** | Debian `.deb` Package & Portable `.tar.gz` | `Mingo-IDE-v1.0.0-Linux-x64.deb`, `Mingo-IDE-v1.0.0-Linux-x64.tar.gz` |
| **Android** | Release APK | `Mingo-IDE-Android.apk` |
| **iOS** | Unsigned IPA & App Archive `.zip` | `Mingo-IDE-iOS-unsigned.ipa`, `Mingo-IDE-iOS-app.zip` |

- **Security & Integrity**: Automatically generates SHA-256 checksums (`SHA256SUMS.txt`) for all compiled artifacts.
- **Automated Verification**: Strict enforcement of `flutter analyze` and `flutter test` before artifact creation.
