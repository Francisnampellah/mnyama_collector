// Production-ready image widget with error handling and loading states
// Demonstrates best practices for rendering images from backend

import 'package:flutter/material.dart';
import '../config/image_config.dart';

// ─── Reusable Image Widget ────────────────────────────────────────────────────

/// Production-ready image widget that handles:
/// - Loading state with skeleton loader
/// - Error state with retry button
/// - Caching and memory optimization
/// - Null/empty path handling
class CaseImageWidget extends StatefulWidget {
  /// Relative path to the image (e.g., 'cases/550e8400-e29b-41d4-a716-446655440000.jpg')
  final String imagePath;

  /// Image width (optional)
  final double? width;

  /// Image height (optional)
  final double? height;

  /// Image fit mode (default: BoxFit.cover)
  final BoxFit fit;

  /// Border radius (optional)
  final BorderRadius? borderRadius;

  /// Optional callback when image load fails
  final Function(dynamic error, StackTrace? stackTrace)? onError;

  /// Optional callback when image loads successfully
  final VoidCallback? onSuccess;

  /// Show loading skeleton while loading (default: true)
  final bool showLoadingSkeleton;

  const CaseImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onError,
    this.onSuccess,
    this.showLoadingSkeleton = true,
  });

  @override
  State<CaseImageWidget> createState() => _CaseImageWidgetState();
}

class _CaseImageWidgetState extends State<CaseImageWidget> {
  late String _imageUrl;
  bool _hasError = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _buildImageUrl();
  }

  void _buildImageUrl() {
    if (widget.imagePath.isEmpty) {
      setState(() => _hasError = true);
      print('[CaseImageWidget] ✗ Empty image path');
      return;
    }

    _imageUrl = ImageUrlBuilder.buildCaseImageUrl(widget.imagePath);

    if (!ImageUrlBuilder.isValidImageUrl(_imageUrl)) {
      setState(() => _hasError = true);
      print('[CaseImageWidget] ✗ Invalid URL built: $_imageUrl');
      return;
    }

    print('[CaseImageWidget] ✓ Image URL ready: $_imageUrl');
  }

  void _retryLoad() {
    setState(() {
      _hasError = false;
      _isRetrying = true;
    });

    // Re-trigger image loading by rebuilding
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if URL is invalid
    if (_hasError) {
      return _buildErrorState();
    }

    // Build image with proper error/loading handling
    return _buildImageWithErrorHandler();
  }

  Widget _buildImageWithErrorHandler() {
    final borderRadius = widget.borderRadius ?? BorderRadius.zero;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        _imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,

        // Handle loading state with skeleton loader
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            // Image loaded successfully
            widget.onSuccess?.call();
            return child;
          }

          if (!widget.showLoadingSkeleton) {
            return const SizedBox.shrink();
          }

          // Calculate progress safely - avoid Infinity/NaN
          double? progress;
          if (loadingProgress.expectedTotalBytes != null &&
              loadingProgress.expectedTotalBytes! > 0) {
            final calculatedProgress =
                loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!;
            // Ensure progress is valid (0-1 range)
            if (calculatedProgress.isFinite &&
                calculatedProgress >= 0 &&
                calculatedProgress <= 1) {
              progress = calculatedProgress;
            }
          }

          return Container(
            width: widget.width,
            height: widget.height,
            color: const Color(0xFFF0F0F0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF1A3D2B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Loading percentage
                  if (progress != null)
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA09D98),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          );
        },

        // Handle error state with retry button
        errorBuilder: (context, error, stackTrace) {
          print('[CaseImageWidget] ✗ Image load failed:');
          print('[CaseImageWidget]   URL: $_imageUrl');
          print('[CaseImageWidget]   Error: $error');
          print('[CaseImageWidget]   Stack: $stackTrace');

          widget.onError?.call(error, stackTrace);

          setState(() => _hasError = true);

          return _buildErrorState();
        },

        // Enable caching for production (only if dimensions are defined and finite)
        cacheHeight: widget.height != null && widget.height!.isFinite
            ? widget.height!.toInt()
            : null,
        cacheWidth: widget.width != null && widget.width!.isFinite
            ? widget.width!.toInt()
            : null,
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBEB),
        borderRadius: widget.borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            size: 32,
            color: Color(0xFFA32D2D),
          ),
          const SizedBox(height: 8),
          const Text(
            'Image failed to load',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFA32D2D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Retry button
          TextButton(
            onPressed: _isRetrying ? null : _retryLoad,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Simple Image Widget (Minimal Version) ────────────────────────────────────

/// Lightweight image widget for simple use cases
class SimpleNetworkImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SimpleNetworkImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageUrlBuilder.buildCaseImageUrl(imagePath);

    if (!ImageUrlBuilder.isValidImageUrl(imageUrl)) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3D2B)),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F0F0),
      child: const Icon(Icons.image_outlined, color: Color(0xFFA09D98)),
    );
  }
}
