enum GitFileStatus {
  modified,
  added,
  untracked,
  deleted,
  unmodified,
}

class FileItem {
  final String id;
  String name;
  String path;
  String content;
  String language;
  bool isFolder;
  bool isOpen;
  bool isDirty;
  List<FileItem>? children;
  GitFileStatus gitStatus;

  FileItem({
    required this.id,
    required this.name,
    required this.path,
    this.content = '',
    this.language = 'plaintext',
    this.isFolder = false,
    this.isOpen = false,
    this.isDirty = false,
    this.children,
    this.gitStatus = GitFileStatus.unmodified,
  });

  FileItem copyWith({
    String? id,
    String? name,
    String? path,
    String? content,
    String? language,
    bool? isFolder,
    bool? isOpen,
    bool? isDirty,
    List<FileItem>? children,
    GitFileStatus? gitStatus,
  }) {
    return FileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      content: content ?? this.content,
      language: language ?? this.language,
      isFolder: isFolder ?? this.isFolder,
      isOpen: isOpen ?? this.isOpen,
      isDirty: isDirty ?? this.isDirty,
      children: children ?? this.children,
      gitStatus: gitStatus ?? this.gitStatus,
    );
  }
}
