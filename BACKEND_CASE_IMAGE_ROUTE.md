# Backend Express Route for Case with Image Upload

## Setup

### 1. Install Dependencies
```bash
npm install multer
```

### 2. Express Route Configuration

Create or update `src/routes/cases.routes.ts`:

```typescript
import { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { authMiddleware } from '../middleware/auth.middleware';
import { CasesController } from '../modules/cases/cases.controller';
import { validateRequest } from '../middleware/validate.middleware';
import { CreateCaseSchema } from '../modules/cases/cases.schemas';

const router = Router();

// Configure multer for single image upload
// Store file in memory (will upload to Supabase Storage in controller)
const uploadStorage = multer.memoryStorage();
const upload = multer({
  storage: uploadStorage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: (req, file, cb) => {
    // Only allow image files
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image files are allowed'));
    }
    cb(null, true);
  },
});

// Existing routes
router.post('/', authMiddleware, validateRequest(CreateCaseSchema), 
  CasesController.createCase);

// NEW: Create case with image in single request
router.post(
  '/with-image',
  authMiddleware,
  upload.single('image'), // Field name must match Flutter: 'image'
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      await CasesController.createCaseWithImage(req, res);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
```

### 3. Controller Implementation

Update `src/modules/cases/cases.controller.ts`:

```typescript
import { Request, Response } from 'express';
import { CasesService } from './cases.service';
import { CreateCaseRequest } from '../../types';

export class CasesController {
  /**
   * Create a case with optional image attachment
   * 
   * Field mapping:
   * - req.body: Case text fields (animalType, severity, symptoms, etc)
   * - req.file: Image file (from multer, field name: 'image')
   * - req.user: Authenticated user (from JWT middleware)
   * 
   * Usage:
   * POST /api/cases/with-image
   * Content-Type: multipart/form-data
   * Authorization: Bearer <token>
   * 
   * Form fields:
   * - diseaseLabelId (required)
   * - animalType (required)
   * - gender (required)
   * - severity (required)
   * - symptoms (required)
   * - breed (optional)
   * - ageMonths (optional)
   * - diagnosis (optional)
   * - notes (optional)
   * - farmLocation (optional)
   * - image (optional): Image file
   */
  static async createCaseWithImage(req: Request, res: Response) {
    console.log('[CasesController] ========== CREATE CASE WITH IMAGE ==========');
    
    try {
      // Log request details
      console.log('[CasesController] User ID:', req.user?.id);
      console.log('[CasesController] Request body fields:', Object.keys(req.body));
      console.log('[CasesController] Case data:', {
        diseaseLabelId: req.body.diseaseLabelId,
        animalType: req.body.animalType,
        gender: req.body.gender,
        severity: req.body.severity,
        symptomsLength: req.body.symptoms?.length,
      });

      // Log file information if present
      if (req.file) {
        console.log('[CasesController] ✓ Image file received:');
        console.log('[CasesController]   - Field name: image');
        console.log('[CasesController]   - File name: ${req.file.originalname}');
        console.log('[CasesController]   - MIME type: ${req.file.mimetype}');
        console.log('[CasesController]   - File size: ${req.file.size} bytes');
        console.log('[CasesController]   - Buffer length: ${req.file.buffer.length}');
      } else {
        console.log('[CasesController] ℹ No image file received');
      }

      // Validate required fields
      const requiredFields = [
        'diseaseLabelId',
        'animalType',
        'gender',
        'severity',
        'symptoms',
      ];

      for (const field of requiredFields) {
        if (!req.body[field]) {
          console.log(
            '[CasesController] ✗ Missing required field: ${field}'
          );
          return res.status(400).json({
            message: 'Missing required field: ${field}',
            code: 'MISSING_FIELD',
          });
        }
      }

      // Convert string values to appropriate types
      const caseData: CreateCaseRequest = {
        userId: req.user!.id,
        diseaseLabelId: req.body.diseaseLabelId,
        animalType: req.body.animalType,
        gender: req.body.gender.toUpperCase(),
        severity: req.body.severity.toUpperCase(),
        symptoms: req.body.symptoms,
        breed: req.body.breed || null,
        ageMonths: req.body.ageMonths ? parseInt(req.body.ageMonths) : null,
        diagnosis: req.body.diagnosis || null,
        notes: req.body.notes || null,
        farmLocation: req.body.farmLocation || null,
      };

      console.log('[CasesController] Creating case with data:', caseData);

      // Call service to create case
      const createdCase = await CasesService.createCase(caseData);

      console.log('[CasesController] ✓ Case created: ${createdCase.id}');

      // If image file present, upload it to Supabase Storage
      let imageUrl: string | undefined;
      if (req.file) {
        console.log('[CasesController] Uploading image to storage...');

        try {
          imageUrl = await CasesService.uploadImageToCase(
            createdCase.id,
            req.file.buffer,
            req.file.originalname,
            req.file.mimetype
          );

          console.log(
            '[CasesController] ✓ Image uploaded successfully: ${imageUrl}'
          );
        } catch (uploadError) {
          console.error('[CasesController] ⚠ Image upload failed:', uploadError);
          // Don't fail the entire request if image upload fails
          // The case is already created
          console.log('[CasesController] Continuing with case creation (image upload failed)');
        }
      }

      // Return created case with optional image URL
      const response = {
        id: createdCase.id,
        diseaseLabelId: createdCase.diseaseLabelId,
        animalType: createdCase.animalType,
        gender: createdCase.gender,
        severity: createdCase.severity,
        symptoms: createdCase.symptoms,
        status: createdCase.status,
        imageUrl: imageUrl || null,
        createdAt: createdCase.createdAt,
      };

      console.log('[CasesController] Response: ${JSON.stringify(response)}');
      console.log('[CasesController] ========== END CREATE CASE WITH IMAGE ==========');

      res.status(201).json({
        message: 'Case created successfully',
        data: response,
      });
    } catch (error) {
      console.error('[CasesController] ✗ Error:', error);
      throw error; // Pass to error middleware
    }
  }

  /**
   * Original create case method (JSON only, no image)
   */
  static async createCase(req: Request, res: Response) {
    console.log('[CasesController] Creating case from JSON...');
    
    try {
      const caseData: CreateCaseRequest = {
        userId: req.user!.id,
        ...req.body,
      };

      const createdCase = await CasesService.createCase(caseData);

      res.status(201).json({
        message: 'Case created successfully',
        data: createdCase,
      });
    } catch (error) {
      throw error;
    }
  }
}
```

### 4. Service Implementation

Update `src/modules/cases/cases.service.ts`:

```typescript
import { prisma } from '../../config/prisma';
import { supabase } from '../../config/supabase';
import { CreateCaseRequest } from '../../types';

export class CasesService {
  /**
   * Create a case in database
   */
  static async createCase(data: CreateCaseRequest) {
    console.log('[CasesService] Creating case:', data);

    const createdCase = await prisma.case.create({
      data: {
        userId: data.userId,
        diseaseLabelId: data.diseaseLabelId,
        animalType: data.animalType,
        breed: data.breed,
        ageMonths: data.ageMonths,
        gender: data.gender,
        symptoms: data.symptoms,
        diagnosis: data.diagnosis,
        notes: data.notes,
        farmLocation: data.farmLocation,
        severity: data.severity,
        status: 'SUBMITTED',
      },
    });

    console.log('[CasesService] Case created with ID:', createdCase.id);
    return createdCase;
  }

  /**
   * Upload image file to Supabase Storage
   */
  static async uploadImageToCase(
    caseId: string,
    fileBuffer: Buffer,
    fileName: string,
    mimeType: string
  ): Promise<string> {
    try {
      console.log('[CasesService] Uploading image to Supabase...');
      console.log('[CasesService] Case ID:', caseId);
      console.log('[CasesService] File name:', fileName);
      console.log('[CasesService] MIME type:', mimeType);
      console.log('[CasesService] Buffer size:', fileBuffer.length);

      // Generate unique file name
      const timestamp = new Date().getTime();
      const uniqueFileName = `cases/${caseId}/${timestamp}-${fileName}`;

      // Upload to Supabase Storage
      const { data, error } = await supabase.storage
        .from('case-images') // Bucket name
        .upload(uniqueFileName, fileBuffer, {
          contentType: mimeType,
          upsert: false,
        });

      if (error) {
        console.error('[CasesService] Upload error:', error);
        throw error;
      }

      console.log('[CasesService] ✓ Upload successful, path:', data?.path);

      // Get public URL
      const { data: publicData } = supabase.storage
        .from('case-images')
        .getPublicUrl(uniqueFileName);

      const publicUrl = publicData?.publicUrl;

      console.log('[CasesService] ✓ Public URL generated:', publicUrl);

      // Store image metadata in database
      const caseImage = await prisma.caseImage.create({
        data: {
          caseId: caseId,
          imageUrl: publicUrl,
          fileName: uniqueFileName,
          mimeType: mimeType,
          fileSize: fileBuffer.length,
        },
      });

      console.log('[CasesService] ✓ Image metadata stored:', caseImage.id);

      return publicUrl;
    } catch (error) {
      console.error('[CasesService] Error uploading image:', error);
      throw error;
    }
  }
}
```

### 5. Type Definitions

Add to `src/types/index.ts`:

```typescript
export interface CreateCaseRequest {
  userId: string;
  diseaseLabelId: string;
  animalType: string;
  breed?: string | null;
  ageMonths?: number | null;
  gender: 'MALE' | 'FEMALE' | 'UNKNOWN';
  symptoms: string;
  diagnosis?: string | null;
  notes?: string | null;
  farmLocation?: string | null;
  severity: 'MILD' | 'MODERATE' | 'SEVERE' | 'CRITICAL';
}
```

## API Usage

### Request Example (cURL)

```bash
curl -X POST http://localhost:4000/api/cases/with-image \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -F "diseaseLabelId=550e8400-e29b-41d4-a716-446655440000" \
  -F "animalType=cow" \
  -F "breed=Holstein" \
  -F "ageMonths=24" \
  -F "gender=MALE" \
  -F "severity=MODERATE" \
  -F "symptoms=Animal showing signs of foot and mouth disease" \
  -F "diagnosis=Confirmed FMD" \
  -F "notes=Isolated from herd" \
  -F "farmLocation=Farm A, District X" \
  -F "image=@/path/to/image.jpg"
```

### Successful Response (201 Created)

```json
{
  "message": "Case created successfully",
  "data": {
    "id": "case-123-abc",
    "diseaseLabelId": "550e8400-e29b-41d4-a716-446655440000",
    "animalType": "cow",
    "gender": "MALE",
    "severity": "MODERATE",
    "symptoms": "Animal showing signs of foot and mouth disease",
    "status": "SUBMITTED",
    "imageUrl": "https://supabase.project.supabase.co/storage/v1/object/public/case-images/cases/case-123-abc/1712900000000-IMG_1234.jpg",
    "createdAt": "2026-04-11T10:30:45.123Z"
  }
}
```

### Error Response (400 Bad Request)

```json
{
  "message": "Missing required field: symptoms",
  "code": "MISSING_FIELD"
}
```

## Debug Logs Expected

When image is uploaded successfully:

```
[CasesController] ========== CREATE CASE WITH IMAGE ==========
[CasesController] User ID: user-123-abc
[CasesController] Request body fields: [...]
[CasesController] Case data: { diseaseLabelId: "...", animalType: "cow", ... }
[CasesController] ✓ Image file received:
[CasesController]   - Field name: image
[CasesController]   - File name: IMG_1234.jpg
[CasesController]   - MIME type: image/jpeg
[CasesController]   - File size: 245678 bytes
[CasesController]   - Buffer length: 245678
[CasesController] Creating case with data: { userId: "...", ... }
[CasesController] ✓ Case created: case-123-abc
[CasesController] Uploading image to storage...
[CasesService] Uploading image to Supabase...
[CasesService] Case ID: case-123-abc
[CasesService] File name: IMG_1234.jpg
[CasesService] MIME type: image/jpeg
[CasesService] Buffer size: 245678
[CasesService] ✓ Upload successful, path: cases/case-123-abc/1712900000000-IMG_1234.jpg
[CasesService] ✓ Public URL generated: https://supabase.project.supabase.co/storage/...
[CasesService] ✓ Image metadata stored: img-123-abc
[CasesController] ✓ Image uploaded successfully: https://supabase.project.supabase.co/...
[CasesController] Response: { id: "case-123-abc", imageUrl: "https://...", ... }
[CasesController] ========== END CREATE CASE WITH IMAGE ==========
```

## Key Points

1. **Multer Configuration**: 
   - Stores file in memory for processing
   - Limits file size to 10MB
   - Only accepts image MIME types

2. **Field Name Matching**: 
   - Flutter sends: `'image'` (MultipartFile field name)
   - Backend receives: `req.file` (multer middleware)
   - Must match exactly

3. **Error Handling**: 
   - Image upload failure doesn't fail case creation
   - Case is saved even if image upload fails
   - Client can retry image upload later

4. **Response Format**: 
   - Returns created case with image URL
   - URL is immediately available for display

5. **Security**: 
   - JWT authentication required
   - MIME type validation
   - File size limits
   - User ID linked to case
