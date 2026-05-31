import 'package:flutter/material.dart';
import 'package:cinewave/shared/utils/link_extractor.dart';

class SourceSelectionDialog extends StatefulWidget {
  final String title;
  final String embedUrl;
  final ValueChanged<String> onUrlResolved;

  const SourceSelectionDialog({
    super.key,
    required this.title,
    required this.embedUrl,
    required this.onUrlResolved,
  });

  @override
  State<SourceSelectionDialog> createState() => _SourceSelectionDialogState();
}

class _SourceSelectionDialogState extends State<SourceSelectionDialog> {
  bool _loading = true;
  String? _resolvedUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      final url = await LinkExtractor.resolve(widget.embedUrl);
      if (!mounted) return;
      setState(() {
        _resolvedUrl = url;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(
        'Download: ${widget.title}',
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Stream resolved successfully',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (_resolvedUrl != null) {
                            widget.onUrlResolved(_resolvedUrl!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Start Download'),
                      ),
                    ],
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}
