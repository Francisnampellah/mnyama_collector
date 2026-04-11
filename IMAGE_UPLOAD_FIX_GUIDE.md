# Fixing 400 Error in Image Upload - Debugging Guide

## Problem
Getting a **400 Bad Request** error when uploading images to `/api/cases/{caseId}/images`

---

## Root Causes & Solutions

### ✅ Fix #1: MIME Type Detection (APPLIED)
**Problem**: Images weren't being sent with correct MIME type
**Solution**: Using `http_parser.dart` and `MediaType` for proper MIME type handling
```dart
request.files.add(
  http.MultipartFile.fromBytes(
    'images',
    fileBytes,
    filename: fileName,
    contentType: MediaType.parse(mimeType), // Now properly set
  ),
);
```

### ✅ Fix #2: Proper File Reading (APPLIED)
**Problem**: Using `file.readAsBytes().asStream()` without awaiting
**Solution**: Using `http.MultipartFile.fromBytes()` which handles async properly
```dart
// Before (broken)
request.files.add(http.MultipartFile(
  'images',
  file.readAsBytes().asStream(), // ✗ Async issue
  fileBytes.length,
));

// After (fixed)
request.files.add(http.MultipartFile.fromBytes(
  'images',
  await fileBytes, // ✓ Properly awaited
  filename: fileName,
  contentType: MediaType.parse(mimeType),
));
```

### ✅ Fix #3: Field Name Case Sensitivity (APPLIED)
**Problem**: Backend expects field name `images` (lowercase, plural)
**Solution**: Ensured exact field name match
```dart
'images' // ✓ Must be 'images' not 'image' or 'Images'
```

---

## What Changed in Your Code

### Updated Method: `uploadCaseImages()`
Located in: `lib/services/case_service.dart` (line 481)

**Changes Made**:
1. ✅ Added import: `import 'package:http_parser/http_parser.dart';`
2. ✅ Added MIME type detection helper method `_getMimeType()`
3. ✅ Changed to `http.MultipartFile.fromBytes()`
4. ✅ Added detailed request logging before sending
5. ✅ Added response body logging for debugging

**New MIME Type Detection**:
```dart
static String _getMimeType(String fileName) {
  final ext = fileName.toLowerCase().split('.').last;
  
  final mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'bmp': 'image/bmp',
    'ico': 'image/x-icon',
  };
  
  return mimeTypes[ext] ?? 'image/jpeg';
}
```

---

## Expected Console Output (Success)

When uploading 2 images, you should see:

```
[CaseService] ========== BEGIN IMAGE UPLOAD ==========
[CaseService] Retrieving authentication token...
[CaseService] Token retrieved: eyJhbGciOiJIUzI1NiIs...
[CaseService] Uploading 2 images for case: 34c67d65-c29e-4445-9034-6f615296893e
[CaseService] Upload endpoint: http://192.168.1.122:4000/api/cases/34c67d65-c29e-4445-9034-6f615296893e/images

[CaseService] Image 1 details:
[CaseService]   - Name: IMG_1234.jpg
[CaseService]   - Size: 245678 bytes
[CaseService]   - MIME type: image/jpeg
[CaseService] ✓ Added image 1/2: IMG_1234.jpg (245678 bytes)

[CaseService] Image 2 details:
[CaseService]   - Name: IMG_1235.png
[CaseService]   - Size: 512345 bytes
[CaseService]   - MIME type: image/png
[CaseService] ✓ Added image 2/2: IMG_1235.png (512345 bytes)

[CaseService] ========= REQUEST DETAILS =========
[CaseService] Method: POST
[CaseService] URL: http://192.168.1.122:4000/api/cases/34c67d65-c29e-4445-9034-6f615296893e/images
[CaseService] Headers: {Authorization: Bearer eyJhbGciOiJIUzI1NiIs...}
[CaseService] Total files: 2
[CaseService] Total fields: 0
[CaseService] File field name: images
[CaseService] File name: IMG_1234.jpg
[CaseService] Content type: image/jpeg
[CaseService] File size: 245678
[CaseService] File field name: images
[CaseService] File name: IMG_1235.png
[CaseService] Content type: image/png
[CaseService] File size: 512345
[CaseService] ====================================

[CaseService] Sending request...
[CaseService] ✓ Response received
[CaseService] Response status: 200
[CaseService] Response body: {"message":"Images uploaded successfully","data":{"caseId":"34c67d65...","uploadedCount":2,"images":[...]}}
```

---

## Expected Console Output (Error - 400)

If you still see a 400 error:

```
[CaseService] Response status: 400
[CaseService] Response body: {"message":"At least one image is required"}

OR

[CaseService] Response status: 400
[CaseService] Response body: {"message":"Invalid file type. Only image/ MIME types allowed"}

OR

[CaseService] Response status: 400
[CaseService] Response body: {"message":"File size exceeds 10MB limit"}
```

**What to check**:
1. ✅ Are images actually being added to the request? (check "Total files")
2. ✅ Is the field name exactly "images"? (check "File field name")
3. ✅ Is MIME type correct? (check "Content type")
4. ✅ Is file size under 10MB? (check "File size")

---

## How to Use the Fixed Code

### Step 1: Ensure Images are Loaded
```dart
// In your submit_case_screen.dart
List<XFile> selectedImages = []; // Images picked from gallery/camera

// Convert to File objects
final List<File> imageFiles = selectedImages
    .map((xfile) => File(xfile.path))
    .toList();

print('[SubmitCaseScreen] Selected images: ${imageFiles.length}');
for (var img in imageFiles) {
  print('[SubmitCaseScreen] Image: ${img.path}');
}
```

### Step 2: Call Upload Method
```dart
try {
  // First create the case
  final newCase = await caseProvider.submitCase(request);
  print('[Screen] Case created: ${newCase.id}');

  // Then upload images
  if (imageFiles.isNotEmpty) {
    print('[Screen] Uploading ${imageFiles.length} images...');
    
    final uploadedImages = await CaseService.uploadCaseImages(
      newCase.id,
      imageFiles,
    );
    
    print('[Screen] ✓ Uploaded ${uploadedImages.length} images');
    
    for (var img in uploadedImages) {
      print('[Screen] Image URL: ${img.imageUrl}');
    }
  }
} catch (e) {
  print('[Screen] ✗ Error: $e');
}
```

### Step 3: Monitor Console Logs
Watch the console output as described above to see:
1. Files being added
2. Request details before sending
3. Response status and body

---

## Backend Requirements Checklist

Make sure your Node.js backend has:

- [ ] `multer` installed: `npm install multer @types/multer`
- [ ] Route configured: `POST /api/cases/:caseId/images`
- [ ] Midwlare: `upload.array('images', 10)`
- [ ] MIME type validation
- [ ] File size validation (10MB per file)
- [ ] Max files validation (10 files per request)

**Correct Express Route**:
```typescript
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
    files: 10,
  },
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only images allowed'));
    }
    cb(null, true);
  },
});

router.post('/:caseId/images', authMiddleware, upload.array('images', 10), controller.uploadImages);
```

---

## Common 400 Errors & Fixes

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `No images provided` | `req.files` is undefined or empty | Check field name is 'images' |
| `Only image/ MIME types allowed` | File MIME type not image | Check file extension and MIME mapping |
| `File size exceeds 10MB` | File is too large | Check file size < 10MB |
| `Invalid file type` | Non-image file selected | Validate file type before upload |

---

## Testing Steps

### 1. Verify Pubspec Dependencies
Ensure you have these in `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  http_parser: ^4.0.0
  image_picker: latest
```

### 2. Test with Single Image
```dart
// Create test case
final testCase = await CaseService.createCase(testRequest);

// Upload single image
final imageFile = File('/path/to/test/image.jpg');
final result = await CaseService.uploadCaseImages(testCase.id, [imageFile]);

print('Result: $result');
```

### 3. Test with Multiple Images
```dart
final images = [
  File('/path/to/image1.jpg'),
  File('/path/to/image2.png'),
  File('/path/to/image3.gif'),
];

final result = await CaseService.uploadCaseImages(caseId, images);
print('Uploaded: ${result.length} images');
```

### 4. Monitor Logs
- ✅ Check field names are 'images'
- ✅ Check MIME types are correct
- ✅ Check file sizes are < 10MB
- ✅ Check authorization header is present
- ✅ Check case ID is in URL

---

## Troubleshooting

### Still Getting 400?

1. **Check your logs for**:
   - Request URL has correct caseId
   - Field names are 'images' (not 'image' or other)
   - All files have correct MIME types
   - Authorization header is present with valid token

2. **Verify backend route**:
   ```bash
   curl -X OPTIONS http://localhost:4000/api/cases/test/images
   ```
   Should return 200 if route exists

3. **Test with cURL**:
   ```bash
   curl -X POST http://localhost:4000/api/cases/{caseId}/images \
     -H "Authorization: Bearer TOKEN" \
     -F "images=@image1.jpg" \
     -F "images=@image2.png"
   ```

4. **Check multer logs on backend**:
   Backend should log which files are accepted/rejected

---

## Next Steps

1. ✅ Update Flutter code (already done)
2. Run `flutter clean && flutter pub get`
3. Test with single image first
4. Gradually increase to 2-3 images
5. Test with different image formats
6. Test with near-10MB images
7. Monitor error responses

---

## Summary of Changes

**File**: `lib/services/case_service.dart`

**Line 2**: Added import for MIME type handling
```dart
import 'package:http_parser/http_parser.dart';
```

**Lines 481-560**: Fixed `uploadCaseImages()` method
- Uses `http.MultipartFile.fromBytes()` for proper async handling
- Adds MIME type detection with `MediaType.parse()`
- Adds detailed request logging

**Lines 636-651**: Added helper method `_getMimeType()`
- Detects MIME type from file extension
- Supports jpg, jpeg, png, gif, webp, bmp, ico

---

**Status**: ✅ READY TO TEST
**Test Now**: Try uploading images and check console logs
**Expected Result**: 200 response with uploaded image details
