# NovaIDE — Cross-Platform Developer Environment

NovaIDE is a full-featured, cross-platform IDE built with Flutter, providing a lightweight yet powerful development environment across Desktop (Windows, macOS, Linux), Web, and Mobile.

## Features

- **Activity Bar & Sidebar**:
  - File Explorer with file/folder tree, creation, renaming, and deletion
  - Full-text search and replace across the workspace
  - Git / Source Control with staged/unstaged changes, commit, and branch management
  - Run & Debug controls with breakpoint and stack trace inspection
  - Extension marketplace with search, install, and categories
  - Remote development manager (SSH, WSL, Dev Containers, Codespaces)
  - Unit and integration test runner
  - Settings panel with customizable themes, editor font sizes, minimap, and line numbers
- **Editor Area**:
  - Tabbed multi-file editor with dirty state indicator
  - Syntax highlighting for 12+ languages (Dart, Rust, TypeScript, JavaScript, Python, HTML, CSS, JSON, Markdown, etc.)
  - Split editor support and customizable minimap
  - Side-by-side Diff editor for Git comparison
  - Interactive Welcome view with quick actions and keyboard shortcuts
- **Bottom Panel**:
  - Interactive terminal emulator with command execution and history
  - Diagnostics / Problems view with file and line links
  - Output streams (Flutter, Build, Tasks)
  - Debug console with runtime evaluation
  - Forwarded ports inspector and preview modal
- **AI Copilot & Assistant**:
  - Integrated AI assistant panel for code explanations, refactoring, and generation
- **Cross-Platform & Mobile Optimization**:
  - Adaptive UI for desktop, tablet, and mobile
  - Mobile bottom navigation, slide-over drawer, and quick coding keyboard toolbar
  - Command Palette (`Ctrl+P` / `Cmd+P`) for rapid navigation and actions

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.12.2)

### Running Locally

```bash
# Get dependencies
flutter pub get

# Run on your desktop platform (e.g. Windows)
flutter run -d windows

# Or run in Chrome / Web
flutter run -d chrome
```

### Running Tests

```bash
flutter test
```
