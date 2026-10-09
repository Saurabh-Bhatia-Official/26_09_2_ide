import 'package:flutter/material.dart';

class ThemeDefinition {
  final String id;
  final String name;
  final bool isDark;
  final Color bgBase;
  final Color bgSurface;
  final Color bgPanel;
  final Color border;
  final Color borderSubtle;
  final Color accent;
  final Color accentGlow;
  final Color textMain;
  final Color textMuted;
  final Color textDim;
  final Color editorBg;

  const ThemeDefinition({
    required this.id,
    required this.name,
    required this.isDark,
    required this.bgBase,
    required this.bgSurface,
    required this.bgPanel,
    required this.border,
    required this.borderSubtle,
    required this.accent,
    required this.accentGlow,
    required this.textMain,
    required this.textMuted,
    required this.textDim,
    required this.editorBg,
  });
}
