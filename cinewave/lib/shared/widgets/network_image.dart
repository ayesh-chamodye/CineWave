import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  /// [width] / [height] — display dimensions.
  ///
  /// [memCacheWidth] / [memCacheHeight] cap the decoded bitmap in the
  /// in-memory LRU cache (in pixels).  A value ≤ 0 means "no cap" and
  /// falls back to the image's native resolution, which burns 4–16×
  /// more VRAM per tile on scroll-heavy lists.
  ///
  /// Displaying a 130 px card from a 342 px source:
  ///   uncapped → ~700 KB decoded bitmap per image
  ///   cap 260×350 → ~35 KB  (20× less VRAM, ~1 ms decode instead of ~12 ms)
  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1F1F1F),
      highlightColor: const Color(0xFF303030),
      period: const Duration(milliseconds: 700),
      child: Container(
        width: width,
        height: height,
        color: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFF1F1F1F),
        child: const Icon(Icons.movie, color: Colors.white54),
      );
    }

    // Cap decoded bitmap to 2 × display resolution (covers 2× retina).
    // Callers can override further with the explicit [memCacheWidth /
    // memCacheHeight] params.  Without an explicit cap CachedNetworkImage
    // decodes the full source resolution (e.g. 342 px → 2000 px), burning
    // 4–16× more VRAM per tile and blocking the UI thread.
    //
    // Guard against Infinity / NaN — these surface when a parent passes
    // `double.infinity` (e.g. Expanded / Flex widgets).  We treat them as
    // "no cap" so CachedNetworkImage keeps full resolution.
    final memW = memCacheWidth ??
        ((width != null && width!.isFinite) ? (width! * 2).toInt() : null);
    final memH = memCacheHeight ??
        ((height != null && height!.isFinite) ? (height! * 2).toInt() : null);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: memW,
      memCacheHeight: memH,
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: const Color(0xFF1F1F1F),
        child: const Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }
}
