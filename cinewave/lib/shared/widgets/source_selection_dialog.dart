import 'package:flutter/material.dart';
import 'package:cinewave/core/models/media_models.dart';

class SourceSelectionDialog extends StatefulWidget {
  final String title;
  final List<VylaSource>? sources;
  final ValueChanged<VylaSource> onSourceSelected;
  final Future<List<VylaSource>> Function()? onLoadSources;

  const SourceSelectionDialog({
    super.key,
    required this.title,
    this.sources,
    required this.onSourceSelected,
    this.onLoadSources,
  });

  @override
  State<SourceSelectionDialog> createState() => _SourceSelectionDialogState();
}

class _SourceSelectionDialogState extends State<SourceSelectionDialog> {
  List<VylaSource>? _loadedSources;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.sources != null) {
      _loadedSources = widget.sources;
    } else if (widget.onLoadSources != null) {
      _loading = true;
      widget.onLoadSources!().then((sources) {
        if (!mounted) return;
        setState(() {
          _loadedSources = sources;
          _loading = false;
        });
      }).catchError((e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(
        'Select source for ${widget.title}',
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
                : _loadedSources == null || _loadedSources!.isEmpty
                    ? const Center(
                        child: Text(
                          'No sources available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _loadedSources!.length,
                        itemBuilder: (context, index) {
                          final source = _loadedSources![index];
                          return ListTile(
                            title: Text(
                              source.quality,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white54, size: 16),
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onSourceSelected(source);
                            },
                          );
                        },
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
