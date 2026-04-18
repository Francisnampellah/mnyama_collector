// Image serving configuration for development and production environments
// Handles backend image URL construction with environment-aware base URLs

class ImageConfig {
  // ─── Development & Production Base URLs ──────────────────────────────────

  /// Base URL for image serving (with ngrok tunnel)
  /// Images are served directly at /uploads/, not under /api
  static const String _devImageBaseUrl ='https://mnyamacollector.afyamnyamaserver.com';

  /// Production image serving base URL (without /uploads path)
  /// Replace with your actual production domain
  static const String _prodImageBaseUrl = 'https://mnyamacollector.afyamnyamaserver.com';

  // ─── Determine which base URL to use ──────────────────────────────────────

  /// Get the appropriate base URL based on environment
  /// For both debug and release: uses ngrok URL
  /// To use production URL, change `false` to `true` below
  static String get imageBaseUrl {
    // Force ngrok URL for all builds (debug and release)
    // Set to false to use production domain when ready
    const bool _forceNgrok = true;

    if (_forceNgrok) {
      return _devImageBaseUrl;
    }

    // For release builds (production APK/app) - only used if _forceNgrok is false
    return _prodImageBaseUrl;
  }

  /// Check if running in debug mode
  static bool get _isDebugBuild {
    return const bool.fromEnvironment('dart.vm.product') == false;
  }

  // ─── Image Path Prefixes ─────────────────────────────────────────────────

  /// Prefix for case-related images in backend storage
  static const String casesImagePrefix = '/uploads/cases/';

  /// Prefix for user-related images in backend storage
  static const String usersImagePrefix = '/uploads/users/';

  /// Prefix for disease label thumbnails
  static const String diseaseImagePrefix = '/uploads/diseases/';

  // ─── MIME Type Configuration ───────────────────────────────────────────────

  /// Allowed image MIME types for upload
  static const List<String> allowedImageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];

  /// Maximum image file size: 10 MB
  static const int maxImageSizeBytes = 10 * 1024 * 1024;

  // ─── Image Caching Configuration ──────────────────────────────────────────

  /// Cache time for images: 7 days
  static const Duration imageCacheDuration = Duration(days: 7);

  /// Enable aggressive caching for production
  static get enableImageCaching => !_isDebugBuild;

  // ─── Logging & Diagnostics ────────────────────────────────────────────────

  static void printImageConfig() {
    const bool _forceNgrok = true;
    print('═' * 60);
    print('[ImageConfig] Image Serving Configuration');
    print('═' * 60);
    print('Environment: ${_isDebugBuild ? "DEBUG" : "RELEASE"}');
    print('Force Ngrok: $_forceNgrok');
    print('Image Base URL: $imageBaseUrl');
    print('Case Images Prefix: $casesImagePrefix');
    print('User Images Prefix: $usersImagePrefix');
    print('Disease Images Prefix: $diseaseImagePrefix');
    print('Max Image Size: ${maxImageSizeBytes ~/ 1024 ~/ 1024} MB');
    print('Caching Enabled: ${enableImageCaching ? "YES" : "NO"}');
    print('═' * 60);
  }
}

// ─── Helper Class: Image URL Builder ────────────────────────────────────────

/// Production-ready helper for constructing image URLs
/// Handles relative paths and converts them to full URLs
class ImageUrlBuilder {
  /// Build a complete image URL from a path or return external URLs as-is
  ///
  /// Handles both:
  /// 1. Internal paths (e.g., 'uploads/cases/550e8400.jpg')
  /// 2. External URLs (e.g., direct URLs starting with http/https)
  ///
  /// Example (internal path):
  ///   Input:  'uploads/cases/c0c837ea-f0d5-4af0-b869-9a8316415afb.jpg'
  ///   Output: 'https://unisexual-relight-absolute.ngrok-free.dev/uploads/cases/c0c837ea-f0d5-4af0-b869-9a8316415afb.jpg'
  ///
  /// Example (external URL):
  ///   Input:  'https://supabase.co/storage/v1/object/public/image/cases/550e8400.jpg'
  ///   Output: 'https://supabase.co/storage/v1/object/public/image/cases/550e8400.jpg' (returned as-is)
  ///
  /// [imagePath] - Relative path or full external URL
  /// Returns: Full URL ready for Image.network()
  static String buildCaseImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      print('[ImageUrlBuilder] ✗ Empty image path provided');
      return '';
    }

    // If it's already a full URL (external service like Supabase), return as-is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      print('[ImageUrlBuilder] External URL detected (using as-is):');
      print('[ImageUrlBuilder]   URL: $imagePath');
      return imagePath;
    }

    // It's an internal path - construct full URL
    // The imageUrl path already includes '/uploads/cases/' prefix
    final fullUrl = '${ImageConfig.imageBaseUrl}/$imagePath';

    print('[ImageUrlBuilder] Case image URL built:');
    print('[ImageUrlBuilder]   Input: $imagePath');
    print('[ImageUrlBuilder]   Output: $fullUrl');

    return fullUrl;
  }

  /// Build a complete image URL for user profile images or return external URLs as-is
  static String buildUserImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      print('[ImageUrlBuilder] ✗ Empty user image path provided');
      return '';
    }

    // If it's already a full URL (external service), return as-is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      print('[ImageUrlBuilder] External URL detected (using as-is):');
      print('[ImageUrlBuilder]   URL: $imagePath');
      return imagePath;
    }

    final cleanPath = imagePath.startsWith('/') ? imagePath : imagePath;
    final fullUrl = '${ImageConfig.imageBaseUrl}/$cleanPath';

    print('[ImageUrlBuilder] User image URL built:');
    print('[ImageUrlBuilder]   Input: $imagePath');
    print('[ImageUrlBuilder]   Output: $fullUrl');

    return fullUrl;
  }

  /// Build a complete image URL for disease labels
  static String buildDiseaseImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      print('[ImageUrlBuilder] ✗ Empty disease image path provided');
      return '';
    }

    final cleanPath = imagePath.startsWith('/') ? imagePath : imagePath;
    final fullUrl =
        '${ImageConfig.imageBaseUrl}${ImageConfig.diseaseImagePrefix}$cleanPath';

    return fullUrl;
  }

  /// Generic URL builder for custom paths
  /// Use when you have a full relative path including the directory prefix
  static String buildImageUrl(String relativePath) {
    if (relativePath.isEmpty) {
      print('[ImageUrlBuilder] ✗ Empty relative path provided');
      return '';
    }

    // If path already starts with /uploads/, don't add it again
    if (relativePath.startsWith('/uploads/')) {
      return '${ImageConfig.imageBaseUrl}$relativePath';
    }

    // Otherwise, assume it's a relative path and construct accordingly
    return '${ImageConfig.imageBaseUrl}$relativePath';
  }

  /// Validate if a URL is properly formed
  static bool isValidImageUrl(String url) {
    try {
      Uri.parse(url);
      return url.isNotEmpty &&
          (url.startsWith('http://') || url.startsWith('https://'));
    } catch (e) {
      print('[ImageUrlBuilder] ✗ Invalid URL: $url');
      return false;
    }
  }
}
