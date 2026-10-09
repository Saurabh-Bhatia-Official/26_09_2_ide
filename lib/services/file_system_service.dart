import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/file_item.dart';

class FileSystemService {
  static String getLanguageByFilename(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    const map = {
      'rs': 'rust',
      'ts': 'typescript',
      'tsx': 'typescript',
      'js': 'javascript',
      'jsx': 'javascript',
      'py': 'python',
      'json': 'json',
      'html': 'html',
      'css': 'css',
      'scss': 'css',
      'md': 'markdown',
      'toml': 'toml',
      'yaml': 'yaml',
      'yml': 'yaml',
      'sql': 'sql',
      'sh': 'shell',
      'bash': 'shell',
      'dart': 'dart',
      'go': 'go',
      'java': 'java',
      'c': 'c',
      'cpp': 'cpp',
      'h': 'c',
      'hpp': 'cpp',
      'cs': 'csharp',
      'php': 'php',
      'kt': 'kotlin',
      'swift': 'swift',
    };
    return map[ext] ?? 'plaintext';
  }

  /// Open directory using FilePicker across Windows, macOS, Linux, Android, iOS, and Web
  static Future<Map<String, dynamic>?> openDirectory() async {
    try {
      final selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select Workspace Directory',
      );

      if (selectedDirectory == null) {
        return null;
      }

      final dir = Directory(selectedDirectory);
      final folderName = dir.path.split(Platform.pathSeparator).last;

      final files = await _scanNativeDirectory(dir, '');
      return {
        'folderName': folderName.isEmpty ? 'Workspace' : folderName,
        'directoryPath': dir.path,
        'files': files,
      };
    } catch (e) {
      debugPrint('Error opening directory: $e');
      return null;
    }
  }

  static Future<List<FileItem>> _scanNativeDirectory(
      Directory dir, String relativeParent) async {
    final List<FileItem> items = [];
    try {
      final entries = await dir.list(followLinks: false).toList();
      for (final entry in entries) {
        final name = entry.path.split(Platform.pathSeparator).last;
        // Ignore heavy folders
        if (name == '.git' ||
            name == 'node_modules' ||
            name == 'target' ||
            name == '.dart_tool' ||
            name == 'build') {
          continue;
        }

        final relPath = relativeParent.isEmpty ? name : '$relativeParent/$name';

        if (entry is Directory) {
          final children = await _scanNativeDirectory(entry, relPath);
          items.add(FileItem(
            id: 'folder-${DateTime.now().microsecondsSinceEpoch}-${items.length}',
            name: name,
            path: relPath,
            isFolder: true,
            children: children,
          ));
        } else if (entry is File) {
          String content = '';
          try {
            final length = await entry.length();
            if (length < 3 * 1024 * 1024) {
              content = await entry.readAsString();
            } else {
              content = '// File exceeds 3MB memory preview limit';
            }
          } catch (_) {
            content = '// Binary or unreadable content';
          }

          items.add(FileItem(
            id: 'file-${DateTime.now().microsecondsSinceEpoch}-${items.length}',
            name: name,
            path: relPath,
            content: content,
            language: getLanguageByFilename(name),
            isFolder: false,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error reading directory ${dir.path}: $e');
    }

    items.sort((a, b) {
      if (a.isFolder == b.isFolder) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return a.isFolder ? -1 : 1;
    });

    return items;
  }

  /// Open single file using FilePicker
  static Future<FileItem?> openSingleFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.any,
      );

      if (file == null) {
        return null;
      }

      String content = '';
      try {
        final bytes = await file.readAsBytes();
        if (bytes.length < 3 * 1024 * 1024) {
          content = utf8.decode(bytes, allowMalformed: true);
        } else {
          content = '// File too large to load in memory';
        }
      } catch (_) {
        content = '';
      }

      return FileItem(
        id: 'file-imported-${DateTime.now().millisecondsSinceEpoch}',
        name: file.name,
        path: file.name,
        content: content,
        language: getLanguageByFilename(file.name),
        isFolder: false,
      );
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }
}
