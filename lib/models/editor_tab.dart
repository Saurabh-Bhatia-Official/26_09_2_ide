class EditorTab {
  final String id;
  final String fileId;
  final String name;
  final String path;
  final String language;
  bool isDirty;
  bool previewMode;

  EditorTab({
    required this.id,
    required this.fileId,
    required this.name,
    required this.path,
    required this.language,
    this.isDirty = false,
    this.previewMode = false,
  });
}
