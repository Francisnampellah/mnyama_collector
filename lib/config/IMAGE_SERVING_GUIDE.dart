// IMAGE SERVING IMPLEMENTATION GUIDE
// Production-Ready Flutter Image URL Handling

/*
═══════════════════════════════════════════════════════════════════════════════
                         OVERVIEW & ARCHITECTURE
═══════════════════════════════════════════════════════════════════════════════

Backend Image Structure:
  /uploads/
    ├── cases/
    │   ├── case-id-1.jpg
    │   ├── case-id-2.png
    │   └── ...
    ├── users/
    │   ├── user-id-1-profile.jpg
    │   └── ...
    └── diseases/
        ├── disease-id-1-thumb.jpg
        └── ...

Files Created:
  1. lib/config/image_config.dart
     - ImageConfig class: Environment-aware base URLs
     - ImageUrlBuilder class: URL construction helpers
  
  2. lib/widgets/case_image_widget.dart
     - CaseImageWidget: Full-featured image with error handling
     - SimpleNetworkImage: Minimal lightweight version

═══════════════════════════════════════════════════════════════════════════════
                        IMPLEMENTATION EXAMPLES
═══════════════════════════════════════════════════════════════════════════════

1. INITIALIZE IMAGE CONFIG (In main.dart):

   void main() {
     // Print image config for debugging
     ImageConfig.printImageConfig();
     
     runApp(const MyApp());
   }

2. BUILD CASE IMAGE URLs:

   // From case model (case has imageUrl or imagePath)
   final imageUrl = ImageUrlBuilder.buildCaseImageUrl(
     'cases/550e8400-e29b-41d4-a716-446655440000.jpg'
   );

3. RENDER IMAGES - Three Approaches:

   A) FULL-FEATURED WIDGET (Recommended for Production):
      
      CaseImageWidget(
        imagePath: 'cases/550e8400-e29b-41d4-a716-446655440000.jpg',
        width: 300,
        height: 200,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
        showLoadingSkeleton: true,
        onSuccess: () {
          print('Image loaded successfully');
        },
        onError: (error, stackTrace) {
          print('Image failed to load: $error');
        },
      )

   B) SIMPLE LIGHTWEIGHT WIDGET:
      
      SimpleNetworkImage(
        imagePath: 'cases/550e8400-e29b-41d4-a716-446655440000.jpg',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      )

   C) MANUAL IMPLEMENTATION (Advanced):
      
      final imageUrl = ImageUrlBuilder.buildCaseImageUrl(imagePath);
      
      Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return const Icon(Icons.image_not_supported);
        },
      )

4. IN VIEW_CASE_DETAIL_SCREEN - Update Image Gallery:

   // Change from:
   child: Image.network(
     img.imageUrl,
     fit: BoxFit.cover,
     ...
   )

   // To:
   child: CaseImageWidget(
     imagePath: img.imageUrl, // backend returns relative path or full URL
     fit: BoxFit.cover,
     borderRadius: BorderRadius.circular(14),
     width: double.infinity,
     height: 260,
   )

5. THUMBNAIL RENDERING IN GALLERY:

   child: SimpleNetworkImage(
     imagePath: images[index].imageUrl,
     width: 60,
     height: 60,
     fit: BoxFit.cover,
   )

═══════════════════════════════════════════════════════════════════════════════
                    ENVIRONMENT CONFIGURATION GUIDE
═══════════════════════════════════════════════════════════════════════════════

The system automatically switches URLs based on environment:

┌─────────────────────┬──────────────────────────────────────────────────────┐
│ Environment         │ Base URL Used                                        │
├─────────────────────┼──────────────────────────────────────────────────────┤
│ Development         │ https://unisexual-relight-absolute.ngrok-free.dev   │
│ (Debug Flutter run) │ /api                                                │
│                     │                                                      │
│ Android Emulator    │ http://10.0.2.2:4000/api                             │
│ (Debug mode)        │ (Special IP to access host machine)                  │
│                     │                                                      │
│ Production APK      │ https://api.mnyama.com                               │
│ (Release build)     │ (Update in ImageConfig._prodImageBaseUrl)            │
└─────────────────────┴──────────────────────────────────────────────────────┘

To Use Production URL:
  1. Edit lib/config/image_config.dart
  2. Change: _prodImageBaseUrl = 'https://your-production-domain.com'
  3. Rebuild release APK

═══════════════════════════════════════════════════════════════════════════════
                      COMMON PITFALLS & SOLUTIONS
═══════════════════════════════════════════════════════════════════════════════

🔴 PITFALL 1: Images Don't Load in Release APK
─────────────────────────────────────────────────
   Problem:
   - Images work in `flutter run` but fail in release APK
   - Common causes:
     * Using ngrok URL (expires after 8 hours)
     * Using localhost/127.0.0.1 (only works on dev machine)
     * Using 10.0.2.2 (Android emulator only, not real device)
   
   Solution:
   - Configure proper production base URL
   - Use HTTPS (not HTTP) for production
   - Ensure backend is accessible from where app is deployed
   - Add SSL certificate verification if needed

🔴 PITFALL 2: Network Images Fail on Slow Connections
─────────────────────────────────────────────────────
   Problem:
   - Images timeout on poor connections
   - App becomes unresponsive during loading
   
   Solution:
   - Add timeout configuration to http client
   - Show placeholder while loading
   - Implement retry mechanism
   - Use lower quality images for thumbnails

🔴 PITFALL 3: Certificate Verification Errors
──────────────────────────────────────────────
   Problem:
   - "Certificate error" or "SSL handshake failed"
   - Often appears in production but not development
   
   Solution:
   - Ensure backend has valid SSL certificate
   - For testing self-signed certs:
     
     override void setupHTTPClient() {
       HttpOverrides.global = MyHttpOverrides();
     }
     
     class MyHttpOverrides extends HttpOverrides {
       @override
       HttpClient createHttpClient(SecurityContext? context) {
         return super.createHttpClient(context)
           ..badCertificateCallback = 
             (X509Certificate cert, String host, int port) => true;
       }
     }

🔴 PITFALL 4: CORS Issues (Web Only)
────────────────────────────────────
   Problem:
   - "No 'Access-Control-Allow-Origin'" error
   - Android/iOS unaffected, but web platform fails
   
   Solution:
   - Configure CORS headers on backend
   - Allow needed origins in backend

🔴 PITFALL 5: Large Images Cause Memory Issues
──────────────────────────────────────────────
   Problem:
   - App crashes with "Out of memory"
   - Happens when loading many or large images
   
   Solution:
   - Implement cacheHeight/cacheWidth
   - Use ImageProvider.precacheImage()
   - Compress images on backend before serving
   - Use lower quality for thumbnails

🔴 PITFALL 6: Missing Image Error Handling
───────────────────────────────────────────
   Problem:
   - Blank space or black spots where images should be
   - No user feedback about load failures
   
   Solution:
   - Always implement errorBuilder
   - Show meaningful error icons/messages
   - Provide retry functionality

🔴 PITFALL 7: Hardcoded Localhost in Release Build
──────────────────────────────────────────────────
   Problem:
   - Using "http://localhost:4000" in production code
   - Works on dev machine, fails everywhere else
   
   Solution:
   - NEVER hardcode localhost in code
   - Use environment-aware configuration
   - This implementation does this correctly

🔴 PITFALL 8: Backend Image Path Changes
────────────────────────────────────────
   Problem:
   - Backend changes from /api/uploads/cases/ to /uploads/cases/
   - All image URLs break
   
   Solution:
   - Centralize URL building in one place
   - Update ImageConfig and all URLs fix automatically
   - That's why we created ImageUrlBuilder!

═══════════════════════════════════════════════════════════════════════════════
                         BACKEND API EXPECTATIONS
═══════════════════════════════════════════════════════════════════════════════

Image Upload Response:
{
  "success": true,
  "images": [
    {
      "id": "img-123",
      "caseId": "case-123",
      "fileName": "photo.jpg",
      "imageUrl": "cases/550e8400-e29b-41d4-a716-446655440000.jpg",
      "mimeType": "image/jpeg",
      "fileSize": 204800,
      "createdAt": "2026-04-15T10:30:00Z"
    }
  ]
}

Image Serving:
GET /api/uploads/cases/550e8400-e29b-41d4-a716-446655440000.jpg
Response: Binary image data
Headers:
  - Content-Type: image/jpeg
  - Cache-Control: public, max-age=31536000 (1 year for released images)

═══════════════════════════════════════════════════════════════════════════════
                            BEST PRACTICES
═══════════════════════════════════════════════════════════════════════════════

✅ DO:
  - Use environment-aware configuration
  - Implement error boundaries and retry
  - Show loading indicators
  - Cache images aggressively
  - Use HTTPS for all URLs
  - Compress images on backend
  - Set reasonable timeouts
  - Add detailed logging for debugging
  - Use image_picker for selecting images
  - Validate URLs before loading

❌ DON'T:
  - Hardcode localhost in production code
  - Use HTTP for production
  - Ignore network errors
  - Load multiple large images simultaneously
  - Store sensitive data in image paths
  - Use ngrok URLs in release builds
  - Forget error handling
  - Load unvalidated URLs
  - Ignore SSL certificate issues
  - Cache forever without invalidation

═══════════════════════════════════════════════════════════════════════════════
                        TESTING CHECKLIST
═══════════════════════════════════════════════════════════════════════════════

Before Release:

  □ Test on Android emulator (10.0.2.2 path)
  □ Test on real Android device (WiFi & cellular)
  □ Test on iOS with VPN disabled
  □ Test with images loading in background
  □ Test with slow network (use Network Link Conditioner)
  □ Test with limited storage space
  □ Verify error handling displays correctly
  □ Check retry mechanism works
  □ Validate image URLs are correct format
  □ Monitor memory usage with DevTools
  □ Test SSL certificate handling
  □ Verify Images persist after app restart
  □ Test image cache clearing

═══════════════════════════════════════════════════════════════════════════════
*/
