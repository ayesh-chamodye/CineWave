import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  Widget _buildShimmer({bool isCircular = false}) {
    final shimmer = Shimmer.fromColors(
      baseColor: const Color(0xFF1F1F1F),
      highlightColor: const Color(0xFF2F2F2F),
      period: const Duration(milliseconds: 900),
      child: Container(
        width: width,
        height: height,
        color: Colors.black,
      ),
    );
    if (isCircular) {
      return ClipOval(child: shimmer);
    }
    return shimmer;
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

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
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
