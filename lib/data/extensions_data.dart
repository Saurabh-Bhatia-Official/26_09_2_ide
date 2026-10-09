import '../constants/app_constants.dart';
import '../models/ide_types.dart';

class ExtensionsData {
  static List<ExtensionItem> getInitialExtensions() {
    return [
      ExtensionItem(
        id: 'rust-analyzer',
        name: 'rust-analyzer',
        displayName: 'rust-analyzer',
        description:
            'First-class Rust language support with full AST, fast code completion and inline type hints.',
        version: '0.4.1950',
        publisher: 'rust-lang',
        downloads: '14.2M',
        rating: 4.9,
        icon: '🦀',
        installed: true,
        category: 'Languages',
      ),
      ExtensionItem(
        id: 'mingo-copilot-pro',
        name: 'mingo-copilot-pro',
        displayName: '${AppConstants.aiAssistantName} Pro AI',
        description:
            'Autonomous coding agent, inline completions, automated unit testing, and contextual code review.',
        version: '2.5.0',
        publisher: '${AppConstants.appName} Systems',
        downloads: '8.7M',
        rating: 5.0,
        icon: '✨',
        installed: true,
        category: 'AI',
      ),
      ExtensionItem(
        id: 'python-pro',
        name: 'python-pro',
        displayName: 'Python Intelligence & Debugger',
        description:
            'Rich support for Python 3.12+, Pylance type checking, pytest runner, and Jupyter notebooks.',
        version: '2025.1.0',
        publisher: 'Microsoft',
        downloads: '45.1M',
        rating: 4.8,
        icon: '🐍',
        installed: true,
        category: 'Languages',
      ),
      ExtensionItem(
        id: 'tokyo-night',
        name: 'tokyo-night',
        displayName: 'Tokyo Night Theme',
        description:
            'A clean, dark Visual Studio Code theme that celebrates the lights of Downtown Tokyo at night.',
        version: '1.0.8',
        publisher: 'enkia',
        downloads: '3.1M',
        rating: 4.9,
        icon: '🌃',
        installed: false,
        category: 'Themes',
      ),
      ExtensionItem(
        id: 'eslint-linter',
        name: 'eslint-linter',
        displayName: 'ESLint & Prettier Integrator',
        description:
            'Integrates ESLint JavaScript and TypeScript into ${AppConstants.appName} with real-time gutter diagnostics.',
        version: '3.0.5',
        publisher: 'Dirk Baeumer',
        downloads: '29.3M',
        rating: 4.7,
        icon: '⚡',
        installed: true,
        category: 'Linters',
      ),
      ExtensionItem(
        id: 'docker-cloud',
        name: 'docker-cloud',
        displayName: 'Docker & Kubernetes Workspaces',
        description:
            'Manage containers, images, compose stacks, and deploy to Kubernetes clusters right from the IDE.',
        version: '1.28.0',
        publisher: 'Docker',
        downloads: '18.9M',
        rating: 4.8,
        icon: '🐳',
        installed: false,
        category: 'Tools',
      ),
      ExtensionItem(
        id: 'git-lens-neo',
        name: 'git-lens-neo',
        displayName: 'GitLens Supercharged',
        description:
            'Supercharge Git within ${AppConstants.appName}: authorship, commit history, visual blame annotations, and branch graphs.',
        version: '15.4.1',
        publisher: 'GitKraken',
        downloads: '22.0M',
        rating: 4.8,
        icon: '🔍',
        installed: true,
        category: 'Tools',
      ),
    ];
  }
}
