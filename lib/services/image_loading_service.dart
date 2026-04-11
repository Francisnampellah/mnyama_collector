import 'package:http/http.dart' as http;

class ImageLoadingService {
  static final ImageLoadingService _instance = ImageLoadingService._internal();

  late http.Client _httpClient;

  factory ImageLoadingService() {
    return _instance;
  }

  ImageLoadingService._internal() {
    _httpClient = http.Client();
  }

  /// Get the HTTP client for image loading
  http.Client getHttpClient() => _httpClient;

  /// Test if an image URL is accessible
  Future<bool> isUrlAccessible(String url) async {
    try {
      print('[ImageLoadingService] Testing URL accessibility: $url');

      final response = await _httpClient
          .head(
            Uri.parse(url),
            headers: {'User-Agent': 'NeTy-Animal-Disease-App/1.0'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('[ImageLoadingService] URL test timeout: $url');
              throw TimeoutException('URL test timeout');
            },
          );

      final isAccessible = response.statusCode == 200;
      print(
        '[ImageLoadingService] URL accessibility (${response.statusCode}): $isAccessible',
      );
      return isAccessible;
    } catch (e) {
      print('[ImageLoadingService] Error testing URL: $e');
      return false;
    }
  }

  /// Download image and check size
  Future<int?> getImageSize(String url) async {
    try {
      print('[ImageLoadingService] Checking image size: $url');

      final response = await _httpClient
          .head(
            Uri.parse(url),
            headers: {'User-Agent': 'NeTy-Animal-Disease-App/1.0'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Size check timeout'),
          );

      final contentLength = response.contentLength;
      print(
        '[ImageLoadingService] Image size: ${contentLength ?? "unknown"} bytes',
      );
      return contentLength;
    } catch (e) {
      print('[ImageLoadingService] Error checking image size: $e');
      return null;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
