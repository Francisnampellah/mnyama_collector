// QUICK REFERENCE: Image Config Usage Examples
// Copy-paste ready code snippets for common scenarios

import 'package:flutter/material.dart';
import '../config/image_config.dart';
import '../widgets/case_image_widget.dart';

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 1: Display Case Image in Gallery
// ═════════════════════════════════════════════════════════════════════════════

class CaseGalleryExample extends StatelessWidget {
  final String
  imagePath; // e.g., 'cases/550e8400-e29b-41d4-a716-446655440000.jpg'

  const CaseGalleryExample({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return CaseImageWidget(
      imagePath: imagePath,
      width: double.infinity,
      height: 260,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(14),
      showLoadingSkeleton: true,
      onSuccess: () {
        print('[Example] Image loaded successfully: $imagePath');
      },
      onError: (error, stackTrace) {
        print('[Example] Image load failed: $error');
        print('[Example] Stack trace: $stackTrace');
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 2: Thumbnail Grid
// ═════════════════════════════════════════════════════════════════════════════

class CaseImageThumbnailGrid extends StatelessWidget {
  final List<String> imagePaths;

  const CaseImageThumbnailGrid({required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return SimpleNetworkImage(
          imagePath: imagePaths[index],
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 3: Build URL Manually for API Calls
// ═════════════════════════════════════════════════════════════════════════════

void exampleBuildImageUrl() {
  // From backend response with relative path
  final relativePath = 'cases/550e8400-e29b-41d4-a716-446655440000.jpg';

  // Build full URL
  final imageUrl = ImageUrlBuilder.buildCaseImageUrl(relativePath);
  print('Image URL: $imageUrl');

  // Example output:
  // Debug: https://unisexual-relight-absolute.ngrok-free.dev/api/uploads/cases/550e8400-e29b-41d4-a716-446655440000.jpg
  // Release: https://api.mnyama.com/uploads/cases/550e8400-e29b-41d4-a716-446655440000.jpg
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 4: List Images with Error States
// ═════════════════════════════════════════════════════════════════════════════

class CaseImageListExample extends StatefulWidget {
  final List<String> imagePaths;

  const CaseImageListExample({required this.imagePaths});

  @override
  State<CaseImageListExample> createState() => _CaseImageListExampleState();
}

class _CaseImageListExampleState extends State<CaseImageListExample> {
  late Set<int> failedImages;

  @override
  void initState() {
    super.initState();
    failedImages = {};
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.imagePaths.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Stack(
            children: [
              CaseImageWidget(
                imagePath: widget.imagePaths[index],
                height: 200,
                fit: BoxFit.cover,
                onError: (error, stackTrace) {
                  // Mark as failed
                  setState(() => failedImages.add(index));
                },
                onSuccess: () {
                  // Mark as loaded
                  setState(() => failedImages.remove(index));
                },
              ),
              // Overlay with index
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Image ${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 5: Main App Initialization (Add to main.dart)
// ═════════════════════════════════════════════════════════════════════════════

/*
void main() {
  // Initialize image config and print info
  ImageConfig.printImageConfig();
  
  // Initialize other services...
  
  runApp(const MyApp());
}

// Add to MyApp build:
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Mnyama Collector',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3D2B)),
    ),
    home: const HomeScreen(),
  );
}
*/

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 6: Image Validation Before Display
// ═════════════════════════════════════════════════════════════════════════════

Widget buildSafeImage(String? imagePath) {
  // Handle null or empty paths
  if (imagePath == null || imagePath.isEmpty) {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: const Icon(Icons.image_outlined),
    );
  }

  // Validate URL format
  final imageUrl = ImageUrlBuilder.buildCaseImageUrl(imagePath);
  if (!ImageUrlBuilder.isValidImageUrl(imageUrl)) {
    return Container(
      color: const Color(0xFFFCEBEB),
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }

  // Safe to display
  return SimpleNetworkImage(imagePath: imagePath);
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 7: Handle Different Image Types
// ═════════════════════════════════════════════════════════════════════════════

class ImageTypeExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Case image
        CaseImageWidget(
          imagePath: 'cases/550e8400-e29b-41d4-a716-446655440000.jpg',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 16),
        // User profile image
        SimpleNetworkImage(
          imagePath: ImageUrlBuilder.buildUserImageUrl(
            'users/user-123-profile.jpg',
          ),
          width: 50,
          height: 50,
        ),
        const SizedBox(height: 16),
        // Disease thumbnail
        SimpleNetworkImage(
          imagePath: ImageUrlBuilder.buildDiseaseImageUrl(
            'diseases/disease-456-thumb.jpg',
          ),
          width: 40,
          height: 40,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 8: Precache Images for Performance
// ═════════════════════════════════════════════════════════════════════════════

Future<void> precacheImagesExample(List<String> imagePaths) async {
  for (final imagePath in imagePaths) {
    final url = ImageUrlBuilder.buildCaseImageUrl(imagePath);
    try {
      await precacheImage(NetworkImage(url), null);
      print('[Precache] ✓ Cached: $imagePath');
    } catch (e) {
      print('[Precache] ✗ Failed to cache: $imagePath ($e)');
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 9: Gallery View with Detailed Error Handling
// ═════════════════════════════════════════════════════════════════════════════

class DetailedGalleryExample extends StatefulWidget {
  final List<String> imagePaths;

  const DetailedGalleryExample({required this.imagePaths});

  @override
  State<DetailedGalleryExample> createState() => _DetailedGalleryExampleState();
}

class _DetailedGalleryExampleState extends State<DetailedGalleryExample> {
  late PageController _pageController;
  int _currentIndex = 0;
  late Map<int, String> _errorMessages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _errorMessages = {};
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              return CaseImageWidget(
                imagePath: widget.imagePaths[index],
                fit: BoxFit.contain,
                onError: (error, stackTrace) {
                  setState(() {
                    _errorMessages[index] = error.toString();
                  });
                },
              );
            },
          ),
        ),
        // Page indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${_currentIndex + 1} / ${widget.imagePaths.length}'
            '${_errorMessages.containsKey(_currentIndex) ? ' (Failed)' : ''}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE 10: Environment Switcher (Debug only)
// ═════════════════════════════════════════════════════════════════════════════

class ImageConfigDebugPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Image Config Debug',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Base URL: ${ImageConfig.imageBaseUrl}',
            style: const TextStyle(color: Colors.green, fontSize: 11),
          ),
          Text(
            'Cases Prefix: ${ImageConfig.casesImagePrefix}',
            style: const TextStyle(color: Colors.green, fontSize: 11),
          ),
          Text(
            'Debug Mode: ${!const bool.fromEnvironment("dart.vm.product")}',
            style: const TextStyle(color: Colors.orange, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// COPY & PASTE: Add to pubspec.yaml if not present
// ═════════════════════════════════════════════════════════════════════════════

/*
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.1.0          # For image selection
  cached_network_image: ^3.3.0  # Optional: for better caching
  connectivity_plus: ^5.0.0     # Optional: for connectivity checks
*/
