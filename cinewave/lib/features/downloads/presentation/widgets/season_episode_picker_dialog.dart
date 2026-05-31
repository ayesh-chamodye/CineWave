import 'package:flutter/material.dart';
import 'package:cinewave/core/models/media_models.dart';

class SeasonEpisodePickerDialog extends StatefulWidget {
  final TVShow tvShow;
  final ValueChanged<int>? onSeasonChanged;

  const SeasonEpisodePickerDialog({
    super.key,
    required this.tvShow,
    this.onSeasonChanged,
  });

  @override
  State<SeasonEpisodePickerDialog> createState() => _SeasonEpisodePickerDialogState();
}

class _SeasonEpisodePickerDialogState extends State<SeasonEpisodePickerDialog> {
  int? _selectedSeason;

  @override
  void initState() {
    super.initState();
    if (widget.tvShow.seasons.isNotEmpty) {
      _selectedSeason = widget.tvShow.seasons.first.seasonNumber;
    }
  }

  int get _episodeCountForCurrentSeason {
    if (_selectedSeason == null || widget.tvShow.seasons.isEmpty) return 0;
    final season = widget.tvShow.seasons.firstWhere(
      (s) => s.seasonNumber == _selectedSeason,
      orElse: () => widget.tvShow.seasons.first,
    );
    return season.episodeCount;
  }

  @override
  Widget build(BuildContext context) {
    final episodeCount = _episodeCountForCurrentSeason;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(
        widget.tvShow.name,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.tvShow.seasons.isEmpty)
              const Text(
                'No seasons available',
                style: TextStyle(color: Colors.white54),
              )
            else ...[
              DropdownButton<int>(
                isExpanded: true,
                hint: const Text(
                  'Select Season',
                  style: TextStyle(color: Colors.white60),
                ),
                value: _selectedSeason,
                items: widget.tvShow.seasons
                    .map((season) => DropdownMenuItem<int>(
                          value: season.seasonNumber,
                          child: Text(
                            'Season ${season.seasonNumber}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeason = value;
                  });
                  widget.onSeasonChanged?.call(value!);
                },
                dropdownColor: Colors.black87,
              ),
              const SizedBox(height: 16),
              if (episodeCount > 0) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Episodes',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodeCount,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final episode = index + 1;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop({'season': _selectedSeason, 'episode': episode});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            episode.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
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
