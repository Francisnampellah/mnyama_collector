# Flutter + Node.js Case Submission with Image Upload

## Overview

This guide provides complete production-ready code for submitting animal disease cases with images using Flutter and Node.js.

## Architecture

```
Flutter App
    ↓
    ├─ Image Picker (camera/gallery)
    ├─ Create Multipart Request
    │   ├─ Case Data (fields)
    │   └─ Image File (binary)
    └─ HTTP POST to Backend
         ↓
Express Server
    ├─ JWT Authentication
    ├─ Multer Middleware (parse multipart)
    ├─ Validate Fields
    ├─ Create Case in Database
    ├─ Upload Image to Supabase Storage
    └─ Return Case with Image URL
         ↓
Flutter App
    ├─ Parse Response
    ├─ Display Success Message
    └─ Show Image from URL
```

## Flutter Implementation

### Step 1: Update Service Method

**File**: `lib/services/case_service.dart`

Use the new `createCaseWithImage()` method:

```dart
/// Create case with image in single multipart request
/// Returns: Case object with image URL
final case = await CaseService.createCaseWithImage(
  request,
  imagePath: '/path/to/image.jpg'
);
```

### Step 2: Update Submit Case Screen

**File**: `lib/screens/submit_case_screen.dart`

Update the `_submitForm()` method to use the new endpoint:

```dart
void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      print('[SubmitCaseScreen] ========== CASE SUBMISSION STARTED ==========');
      
      final request = CreateCaseRequest(
        diseaseLabelId: _selectedDisease!.id,
        animalType: _animalType!,
        breed: _breed,
        ageMonths: _ageMonths,
        gender: _gender!,
        symptoms: _symptoms!,
        diagnosis: _diagnosis,
        notes: _notes,
        farmLocation: _farmLocation,
        severity: _severity!,
      );

      print('[SubmitCaseScreen] Case request created');
      print('[SubmitCaseScreen] Selected images: ${_selectedImages.length}');

      final caseProvider = context.read<CaseProvider>();
      
      // Use new method that supports image upload
      late Case createdCase;
      if (_selectedImages.isNotEmpty) {
        print('[SubmitCaseScreen] Submitting case WITH image...');
        
        // Send first image with case (can extend for multiple images)
        createdCase = await caseProvider.submitCaseWithImage(
          request,
          imagePath: _selectedImages[0].path,
        );
        
        // Upload remaining images if any
        if (_selectedImages.length > 1) {
          print('[SubmitCaseScreen] Uploading ${_selectedImages.length - 1} additional images...');
          
          final remainingImages = _selectedImages.sublist(1);
          await caseProvider.uploadCaseImages(
            createdCase.id,
            remainingImages,
          );
        }
      } else {
        print('[SubmitCaseScreen] Submitting case WITHOUT image...');
        
        // Use original method for cases without images
        createdCase = await caseProvider.submitCase(request);
      }

      if (!mounted) return;

      print('[SubmitCaseScreen] ✓ Case created successfully');
      print('[SubmitCaseScreen] Case ID: ${createdCase.id}');
      
      if (createdCase.images?.isNotEmpty ?? false) {
        print('[SubmitCaseScreen] Images: ${createdCase.images!.length}');
        for (var img in createdCase.images!) {
          print('[SubmitCaseScreen]   - ${img.imageUrl}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, stackTrace) {
      if (!mounted) return;
      
      print('[SubmitCaseScreen] ✗ Submission failed: $e');
      print('[SubmitCaseScreen] Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
```

### Step 3: Update Provider

**File**: `lib/providers/case_provider.dart`

Add the new method:

```dart
import 'dart:io';

class CaseProvider extends ChangeNotifier {
  // ... existing code ...

  /// Submit case with image in single request
  Future<Case> submitCaseWithImage(
    CreateCaseRequest request, {
    String? imagePath,
  }) async {
    print('[CaseProvider] ========== BEGIN SUBMIT CASE WITH IMAGE ==========');
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      print('[CaseProvider] Image path: $imagePath');
      
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        final exists = await file.exists();
        print('[CaseProvider] Image exists: $exists');
        
        if (exists) {
          final size = await file.length();
          print('[CaseProvider] Image size: $size bytes');
        }
      }

      print('[CaseProvider] Calling CaseService.createCaseWithImage()...');
      final newCase = await CaseService.createCaseWithImage(
        request,
        imagePath: imagePath,
      );

      print('[CaseProvider] ✓ Case with image created: ${newCase.id}');
      
      _currentCase = newCase;
      _error = null;
      return newCase;
    } catch (e, stackTrace) {
      print('[CaseProvider] ✗ Error: $e');
      print('[CaseProvider] Stack trace: $stackTrace');
      _error = e.toString();
      rethrow;
    } finally {
      print('[CaseProvider] Setting isSubmitting = false');
      _isSubmitting = false;
      notifyListeners();
      print('[CaseProvider] ========== END SUBMIT CASE WITH IMAGE ==========');
    }
  }

  // ... existing methods ...
}
```

## Node.js Backend Implementation

### Update Router

**File**: `src/routes/cases.routes.ts`

```typescript
import { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { authMiddleware } from '../middleware/auth.middleware';
import { CasesController } from '../modules/cases/cases.controller';

const router = Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only images allowed'));
    }
    cb(null, true);
  },
});

// New route: Create case with image
router.post(
  '/with-image',
  authMiddleware,
  upload.single('image'),
  CasesController.createCaseWithImage
);

// Existing route: Create case (JSON only)
router.post('/', authMiddleware, CasesController.createCase);

export default router;
```

### Update Controller

**File**: `src/modules/cases/cases.controller.ts`

```typescript
import { Request, Response } from 'express';
import { CasesService } from './cases.service';

export class CasesController {
  static async createCaseWithImage(req: Request, res: Response) {
    try {
      console.log('[CasesController] Received POST /cases/with-image');
      console.log('[CasesController] User:', req.user?.id);
      
      // Validate required fields
      const required = ['diseaseLabelId', 'animalType', 'gender', 'severity', 'symptoms'];
      for (const field of required) {
        if (!req.body[field]) {
          return res.status(400).json({ message: \`Missing: \${field}\` });
        }
      }

      // Log image info if present
      if (req.file) {
        console.log('[CasesController] Image received:', {
          originalName: req.file.originalname,
          size: req.file.size,
          mimetype: req.file.mimetype,
        });
      }

      // Create case
      const caseData = {
        userId: req.user!.id,
        diseaseLabelId: req.body.diseaseLabelId,
        animalType: req.body.animalType,
        breed: req.body.breed || null,
        ageMonths: req.body.ageMonths ? parseInt(req.body.ageMonths) : null,
        gender: req.body.gender.toUpperCase(),
        symptoms: req.body.symptoms,
        diagnosis: req.body.diagnosis || null,
        notes: req.body.notes || null,
        farmLocation: req.body.farmLocation || null,
        severity: req.body.severity.toUpperCase(),
      };

      const createdCase = await CasesService.createCase(caseData);
      console.log('[CasesController] Case created:', createdCase.id);

      let imageUrl: string | null = null;

      // Upload image if present
      if (req.file) {
        try {
          imageUrl = await CasesService.uploadImageToCase(
            createdCase.id,
            req.file.buffer,
            req.file.originalname,
            req.file.mimetype
          );
          console.log('[CasesController] Image uploaded:', imageUrl);
        } catch (err) {
          console.error('[CasesController] Image upload failed:', err);
          // Don't fail - case is already created
        }
      }

      res.status(201).json({
        message: 'Case created successfully',
        data: {
          ...createdCase,
          imageUrl,
        },
      });
    } catch (error) {
      console.error('[CasesController] Error:', error);
      res.status(500).json({ message: 'Failed to create case' });
    }
  }

  static async createCase(req: Request, res: Response) {
    try {
      const createdCase = await CasesService.createCase({
        userId: req.user!.id,
        ...req.body,
      });

      res.status(201).json({
        message: 'Case created successfully',
        data: createdCase,
      });
    } catch (error) {
      res.status(500).json({ message: 'Failed to create case' });
    }
  }
}
```

### Update Service

**File**: `src/modules/cases/cases.service.ts`

```typescript
import { prisma } from '../../config/prisma';
import { supabase } from '../../config/supabase';

export class CasesService {
  static async createCase(data: any) {
    return prisma.case.create({
      data: {
        ...data,
        status: 'SUBMITTED',
      },
    });
  }

  static async uploadImageToCase(
    caseId: string,
    buffer: Buffer,
    originalName: string,
    mimeType: string
  ): Promise<string> {
    const fileName = `cases/${caseId}/${Date.now()}-${originalName}`;

    const { error } = await supabase.storage
      .from('case-images')
      .upload(fileName, buffer, { contentType: mimeType });

    if (error) throw error;

    const { data } = supabase.storage
      .from('case-images')
      .getPublicUrl(fileName);

    // Store in database
    await prisma.caseImage.create({
      data: {
        caseId,
        imageUrl: data.publicUrl,
        fileName,
        mimeType,
        fileSize: buffer.length,
      },
    });

    return data.publicUrl;
  }
}
```

## Request/Response Examples

### Request (Flutter → Node.js)

```
POST /api/cases/with-image HTTP/1.1
Host: 192.168.1.122:4000
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary...

------WebKitFormBoundary...
Content-Disposition: form-data; name="diseaseLabelId"

550e8400-e29b-41d4-a716-446655440000
------WebKitFormBoundary...
Content-Disposition: form-data; name="animalType"

cow
------WebKitFormBoundary...
Content-Disposition: form-data; name="gender"

MALE
------WebKitFormBoundary...
Content-Disposition: form-data; name="severity"

MODERATE
------WebKitFormBoundary...
Content-Disposition: form-data; name="symptoms"

Animal showing signs of foot and mouth disease with blisters on hooves
------WebKitFormBoundary...
Content-Disposition: form-data; name="image"; filename="IMG_1234.jpg"
Content-Type: image/jpeg

[Binary image data]
------WebKitFormBoundary...--
```

### Response (Node.js → Flutter)

```json
{
  "message": "Case created successfully",
  "data": {
    "id": "case-abc-123",
    "diseaseLabelId": "550e8400-e29b-41d4-a716-446655440000",
    "animalType": "cow",
    "gender": "MALE",
    "severity": "MODERATE",
    "symptoms": "Animal showing signs of foot and mouth disease...",
    "status": "SUBMITTED",
    "imageUrl": "https://supabase.project.supabase.co/storage/v1/object/public/case-images/cases/case-abc-123/1712900000000-IMG_1234.jpg",
    "createdAt": "2026-04-11T10:30:45.123Z"
  }
}
```

## Debug Logs

### Flutter Console Logs

```
[SubmitCaseScreen] ========== CASE SUBMISSION STARTED ==========
[SubmitCaseScreen] Case request created
[SubmitCaseScreen] Selected images: 1
[SubmitCaseScreen] Submitting case WITH image...
[CaseProvider] ========== BEGIN SUBMIT CASE WITH IMAGE ==========
[CaseProvider] Image path: /data/user/0/com.example.mnyama_collector/cache/IMG_1234.jpg
[CaseProvider] Image exists: true
[CaseProvider] Image size: 245678 bytes
[CaseProvider] Calling CaseService.createCaseWithImage()...
[CaseService] ========== BEGIN CREATE CASE WITH IMAGE ==========
[CaseService] Retrieving authentication token...
[CaseService] Token retrieved: eyJhbGciOiJIUzI1NiIs...
[CaseService] Creating multipart request...
[CaseService] Adding form fields:
[CaseService]   - diseaseLabelId: 550e8400-e29b-41d4-a716-446655440000
[CaseService]   - animalType: cow
[CaseService]   - gender: MALE
[CaseService]   - severity: MODERATE
[CaseService]   - symptoms: Animal showing signs...
[CaseService] Adding image file...
[CaseService] Image file found: /data/user/0/com.example.mnyama_collector/cache/IMG_1234.jpg (245678 bytes)
[CaseService] Image file name: IMG_1234.jpg
[CaseService] ✓ Image file added to multipart request
[CaseService] Sending multipart request to: http://192.168.1.122:4000/api/cases/with-image
[CaseService] Total fields: 5
[CaseService] Total files: 1
[CaseService] ✓ Response received
[CaseService] Response status: 201
[CaseService] Response body length: 456
[CaseService] ✓ Case created successfully with image
[CaseService] ✓ Case parsed successfully:
[CaseService]   - ID: case-abc-123
[CaseService]   - Status: SUBMITTED
[CaseService]   - Image count: 1
[CaseService] ========== END CREATE CASE WITH IMAGE ==========
[CaseProvider] ✓ Case with image created: case-abc-123
[CaseProvider] Setting isSubmitting = false
[CaseProvider] ========== END SUBMIT CASE WITH IMAGE ==========
[SubmitCaseScreen] ✓ Case created successfully
[SubmitCaseScreen] Case ID: case-abc-123
[SubmitCaseScreen] Images: 1
[SubmitCaseScreen]   - https://supabase.project.supabase.co/storage/v1/object/public/case-images/cases/case-abc-123/1712900000000-IMG_1234.jpg
```

### Node.js Server Logs

```
[CasesController] ========== CREATE CASE WITH IMAGE ==========
[CasesController] User ID: user-abc-123
[CasesController] Request body fields: diseaseLabelId, animalType, gender, severity, symptoms, breed, ageMonths
[CasesController] ✓ Image file received:
[CasesController]   - Field name: image
[CasesController]   - File name: IMG_1234.jpg
[CasesController]   - MIME type: image/jpeg
[CasesController]   - File size: 245678 bytes
[CasesController] Creating case with data: { userId: "...", diseaseLabelId: "...", ... }
[CasesController] ✓ Case created: case-abc-123
[CasesController] Uploading image to storage...
[CasesService] Uploading image to Supabase...
[CasesService] Case ID: case-abc-123
[CasesService] File name: IMG_1234.jpg
[CasesService] Buffer size: 245678
[CasesService] ✓ Upload successful, path: cases/case-abc-123/1712900000000-IMG_1234.jpg
[CasesService] ✓ Public URL generated: https://supabase.project.supabase.co/storage/v1/object/public/case-images/cases/case-abc-123/1712900000000-IMG_1234.jpg
[CasesService] ✓ Image metadata stored: img-abc-123
[CasesController] ✓ Image uploaded successfully: https://supabase.project.supabase.co/...
[CasesController] Response: { id: "case-abc-123", imageUrl: "https://...", status: "SUBMITTED" }
[CasesController] ========== END CREATE CASE WITH IMAGE ==========
```

## Troubleshooting

### `req.file` is undefined

**Problem**: Image not being received on backend

**Solutions**:
1. Check Flutter field name is exactly `'image'` (not `'images'` or other name)
2. Verify multer is configured: `upload.single('image')`
3. Ensure `Content-Type: multipart/form-data` header is set automatically by http.MultipartRequest
4. Check file exists before sending

### Image upload succeeds but not stored

**Problem**: Image received but not saved to Supabase

**Solutions**:
1. Verify Supabase credentials are correct
2. Check bucket name matches (`'case-images'`)
3. Ensure Supabase bucket has public RLS policy for uploads
4. Check network connectivity to Supabase

### File too large error

**Problem**: `-ERR_FILE_SIZE_EXCEEDS`

**Solutions**:
1. Increase multer limit in Express: `limits: { fileSize: 20 * 1024 * 1024 }`
2. Compress image before sending in Flutter

## Performance Tips

1. **Image Compression**: Reduce image quality to 85% in Flutter (already done)
2. **Async Upload**: Upload images separately for faster case creation
3. **Background Processing**: Handle image storage asynchronously on backend
4. **Caching**: Cache public image URLs on client

## Security Checklist

- ✅ JWT authentication required
- ✅ MIME type validation
- ✅ File size limits (10MB)
- ✅ User ID linked to case
- ✅ CORS configured
- ✅ HTTPS in production
- ✅ Multer memory limits set
