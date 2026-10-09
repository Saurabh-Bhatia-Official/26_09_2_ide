import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workspace_provider.dart';
import '../../constants/app_constants.dart';

class PortPreviewModal extends StatelessWidget {
  const PortPreviewModal({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkspaceProvider>();
    final previewUrl = wp.previewUrl;
    if (previewUrl == null) return const SizedBox.shrink();

    final theme = wp.theme;

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: () => wp.setPreviewUrl(null),
          child: Container(color: Colors.black.withValues(alpha: 0.65)),
        ),
        // Preview Window
        Center(
          child: Container(
            width: 780,
            height: 520,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
              boxShadow: const [
                BoxShadow(color: Colors.black87, blurRadius: 40, offset: Offset(0, 15)),
              ],
            ),
            child: Column(
              children: [
                // Browser Top Nav
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: theme.bgPanel,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                    border: Border(bottom: BorderSide(color: theme.border)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.public, size: 14, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${AppConstants.appName} Integrated Web Preview',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textMain),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: theme.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  previewUrl,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.white70),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('SSL/TLS', style: TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.close, size: 15),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        onPressed: () => wp.setPreviewUrl(null),
                      ),
                    ],
                  ),
                ),

                // Simulated Live App Preview
                Expanded(
                  child: Container(
                    color: const Color(0xFF0F172A),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.rocket_launch, size: 32, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${AppConstants.appName} Live Web Server',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Application running at http://localhost:5173 with Instant HMR',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                                SizedBox(width: 6),
                                Text('Local Host Connected • 142ms build time',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
