import 'package:flutter/material.dart';
import 'package:cinewave/core/constants/app_constants.dart';

/// Modal bottom-sheet dialog that lets the user pick a streaming player-server.
///
/// One radio card per server; tapping a card pops the sheet with the chosen
/// [AppServer] as the result.  `null` is returned on dismiss.
class ServerPickerDialog extends StatelessWidget {
  final String currentEmbedUrl;

  const ServerPickerDialog({super.key, required this.currentEmbedUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Select Player',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(AppServer.all.length, (index) {
            final server = AppServer.all[index];
            final isSelected =
                server.host == AppConstants.selectedServer.host;
            return _ServerRowTile(
              server: server,
              isSelected: isSelected,
              onTap: () => Navigator.of(context).pop(server),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ServerRowTile extends StatelessWidget {
  final AppServer server;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServerRowTile({
    required this.server,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0x1AFFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? server.color.withValues(alpha: 0.6)
                  : Colors.white10,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              // Colour dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: server.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              // Label
              Expanded(
                child: Text(
                  server.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Radio ring / dot
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? server.color
                        : Colors.white.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: server.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
