# Image Upload - Complete Logging Trace

Enhanced with comprehensive logging to track every step of image upload.

---

## ✅ What's Been Added

**Files Updated**:
- `lib/services/case_service.dart` - Detailed logging in `uploadCaseImages()`
- `lib/providers/case_provider.dart` - Already has good logging
- `lib/screens/submit_case_screen.dart` - Added detailed image validation logs

---

## 📋 Complete Expected Console Output

### Step 1: User Selects Images
```
[SubmitCaseScreen] Image added to list. Total images: 1
[SubmitCaseScreen] Image added to list. Total images: 2
```

### Step 2: User Submits Form
```
[SubmitCaseScreen] ========== CASE SUBMISSION STARTED ==========
[SubmitCaseScreen] Form validation: PASSED
[SubmitCaseScreen] Case request created:
[SubmitCaseScreen]   - Disease ID: 1d673896-ea79-4bac-8c69-836615074e2a
[SubmitCaseScreen]   - Animal Type: cow
[SubmitCaseScreen]   - Gender: Gender.MALE
[SubmitCaseScreen]   - Severity: CaseSeverity.MODERATE
[SubmitCaseScreen] Submitting case to provider...
```

### Step 3: Create Case
```
[CaseProvider] ========== BEGIN CASE SUBMISSION ==========
[CaseProvider] Setting isSubmitting = true
[CaseProvider] Calling CaseService.createCase()...
[CaseService] ========== BEGIN CREATE CASE ==========
[CaseService] Retrieving authentication token...
[CaseService] Token retrieved: eyJhbGciOiJIUzI1NiIs...
[CaseService] Sending case data to: http://192.168.1.122:4000/api/cases
[CaseService] Response status: 201
[CaseService] √ Case created successfully
[CaseService] ========== END CREATE CASE ==========
[CaseProvider] ✓ Case created successfully
[SubmitCaseScreen] ✓ Case submitted successfully!
[SubmitCaseScreen] Case ID: 34c67d65-c29e-4445-9034-6f615296893e
```

### Step 4: Validate Images Before Upload (NEW!)
```
[SubmitCaseScreen] 
[SubmitCaseScreen] ========== STARTING IMAGE UPLOAD ==========
[SubmitCaseScreen] Total images to upload: 2
[SubmitCaseScreen] Image 1:
[SubmitCaseScreen]   - Path: /data/user/0/com.example.mnyama_collector/cache/IMG_1234.jpg
[SubmitCaseScreen]   - Type: File
[SubmitCaseScreen]   - Exists: true
[SubmitCaseScreen]   - Size: 245678 bytes
[SubmitCaseScreen] Image 2:
[SubmitCaseScreen]   - Path: /data/user/0/com.example.mnyama_collector/cache/IMG_1235.png
[SubmitCaseScreen]   - Type: File
[SubmitCaseScreen]   - Exists: true
[SubmitCaseScreen]   - Size: 512345 bytes

[SubmitCaseScreen] 
[SubmitCaseScreen] Passing images to provider...
[SubmitCaseScreen] - Case ID: 34c67d65-c29e-4445-9034-6f615296893e
[SubmitCaseScreen] - Images count: 2
[SubmitCaseScreen] - Images type: List<File>
```

### Step 5: Provider Processing (NEW!)
```
[CaseProvider] ========== BEGIN IMAGE UPLOAD ==========
[CaseProvider] Setting isSubmitting = true
[CaseProvider] Uploading 2 images for case: 34c67d65-c29e-4445-9034-6f615296893e
[CaseProvider]   Image 1/2: /data/user/0/com.example.mnyama_collector/cache/IMG_1234.jpg (245678 bytes)
[CaseProvider]   Image 2/2: /data/user/0/com.example.mnyama_collector/cache/IMG_1235.png (512345 bytes)
[CaseProvider] Calling CaseService.uploadCaseImages()...
```

### Step 6: Service Input Validation (NEW!)
```
[CaseService] ========== BEGIN IMAGE UPLOAD ==========
[CaseService] Input validation:
[CaseService]   - Case ID: 34c67d65-c29e-4445-9034-6f615296893e
[CaseService]   - Number of images passed: 2
[CaseService]   - Images list type: List<File>
[CaseService]   - Images list isEmpty: false
[CaseService] Input image 0:
[CaseService]   - Path: /data/user/0/com.example.mnyama_collector/cache/IMG_1234.jpg
[CaseService]   - Type: File
[CaseService]   - Exists (before upload): true
[CaseService] Input image 1:
[CaseService]   - Path: /data/user/0/com.example.mnyama_collector/cache/IMG_1235.png
[CaseService]   - Type: File
[CaseService]   - Exists (before upload): true
```

### Step 7: Authentication & Preparation (NEW!)
```
[CaseService] Retrieving authentication token...
[CaseService] Token retrieved: eyJhbGciOiJIUzI1NiIs...
[CaseService] ✓ Uploading 2 images for case: 34c67d65-c29e-4445-9034-6f615296893e
[CaseService] Upload endpoint: http://192.168.1.122:4000/api/cases/34c67d65-c29e-4445-9034-6f615296893e/images
[CaseService] ✓ MultipartRequest created
[CaseService] ✓ Authorization header added
[CaseService] Starting to add images to request...
```

### Step 8: Processing Each Image (NEW!)
```
[CaseService] 
[CaseService] === IMAGE 1/2 ===
[CaseService] File path: /data/user/0/com.example.mnyama_collector/cache/IMG_1234.jpg
[CaseService] File exists: true
[CaseService] Reading file bytes...
[CaseService] ✓ File bytes read: 245678 bytes
[CaseService] File name: IMG_1234.jpg
[CaseService] MIME type detected: image/jpeg
[CaseService] Creating MultipartFile...
[CaseService] MultipartFile created:
[CaseService]   - Field name: images
[CaseService]   - File name: IMG_1234.jpg
[CaseService]   - Content-Type: image/jpeg
[CaseService]   - Size: 245678
[CaseService] Adding MultipartFile to request...
[CaseService] ✓ File added to request
[CaseService] Current request file count: 1

[CaseService] 
[CaseService] === IMAGE 2/2 ===
[CaseService] File path: /data/user/0/com.example.mnyama_collector/cache/IMG_1235.png
[CaseService] File exists: true
[CaseService] Reading file bytes...
[CaseService] ✓ File bytes read: 512345 bytes
[CaseService] File name: IMG_1235.png
[CaseService] MIME type detected: image/png
[CaseService] Creating MultipartFile...
[CaseService] MultipartFile created:
[CaseService]   - Field name: images
[CaseService]   - File name: IMG_1235.png
[CaseService]   - Content-Type: image/png
[CaseService]   - Size: 512345
[CaseService] Adding MultipartFile to request...
[CaseService] ✓ File added to request
[CaseService] Current request file count: 2
```

### Step 9: Final Request Details Before Send (NEW!) ⭐ **CRITICAL**
```
[CaseService] 
[CaseService] ========= FINAL REQUEST DETAILS BEFORE SEND =========
[CaseService] Method: POST
[CaseService] URL: http://192.168.1.122:4000/api/cases/34c67d65-c29e-4445-9034-6f615296893e/images
[CaseService] Headers:
[CaseService]   - Authorization: eyJhbGciOiJIUzI1NiIs...
[CaseService] Total files in request: 2
[CaseService] Total fields in request: 0
[CaseService] Files in request:
[CaseService]   File 1:
[CaseService]     - Field: images
[CaseService]     - Name: IMG_1234.jpg
[CaseService]     - Type: image/jpeg
[CaseService]     - Size: 245678
[CaseService]   File 2:
[CaseService]     - Field: images
[CaseService]     - Name: IMG_1235.png
[CaseService]     - Type: image/png
[CaseService]     - Size: 512345
[CaseService] =============================================
```

**⚠️ If you see this, stop and check:**
- ❌ `Total files in request: 0` → Files not being added (ERROR!)
- ❌ `Field name is NOT "images"` → Wrong field name (ERROR!)
- ✅ `Total files in request: 2` → Correct!

### Step 10: Send Request & Get Response (NEW!)
```
[CaseService] Sending request...
[CaseService] ✓ Request sent successfully
[CaseService] ✓ Response received
[CaseService] Response status: 200
[CaseService] Response body: {"message":"Images uploaded successfully","data":{"caseId":"34c67d65-c29e-4445-9034-6f615296893e","uploadedCount":2,"images":[{"id":"img-123","fileName":"IMG_1234.jpg","imageUrl":"https://supabase.../","fileSize":245678,"mimeType":"image/jpeg","createdAt":"2026-04-11T13:30:45.123Z"},{"id":"img-124","fileName":"IMG_1235.png","imageUrl":"https://supabase.../","fileSize":512345,"mimeType":"image/png","createdAt":"2026-04-11T13:30:46.456Z"}]}}
[CaseService] Response headers: {content-type: application/json, ...}
```

### Step 11: Parse Response (NEW!)
```
[CaseService] Response format: Map with "data" key
[CaseService] Parsed 2 image records from response
[CaseService] ✓ Successfully parsed 2 images
[CaseService]   Image 1: https://supabase.project.supabase.co/storage/.../IMG_1234.jpg
[CaseService]   Image 2: https://supabase.project.supabase.co/storage/.../IMG_1235.png
[CaseService] ========== END IMAGE UPLOAD ==========
```

### Step 12: Provider & Screen Completion (NEW!)
```
[CaseProvider] ✓ All images uploaded successfully
[CaseProvider] Setting isSubmitting = false
[CaseProvider] ========== END IMAGE UPLOAD ==========

[SubmitCaseScreen] ✓ All images uploaded successfully!
[SubmitCaseScreen] ========== CASE SUBMISSION COMPLETE ==========

ScaffoldMessenger shows: "Case created with 2 image(s)!"
```

---

## 🔴 If No Images Are Sent - What to Look For

### Problem 1: Images List is Empty
```
[SubmitCaseScreen] ========== STARTING IMAGE UPLOAD ==========
[SubmitCaseScreen] Total images to upload: 0  ← ❌ PROBLEM!
```
**Solution**: Check if images are actually being selected from gallery

### Problem 2: Images Not Passed to Provider
```
[SubmitCaseScreen] Passing images to provider...
[SubmitCaseScreen] - Images count: 0  ← ❌ PROBLEM!
```
**Solution**: Check `_selectedImages` list - is it populated?

### Problem 3: Files Don't Exist
```
[CaseService] File exists: false  ← ❌ PROBLEM!
[CaseService] ✗ Image 1 not found: /path/to/image.jpg
```
**Solution**: Image file was deleted or path is wrong

### Problem 4: No Files in Request
```
[CaseService] Total files in request: 0  ← ❌ CRITICAL ERROR!
[CaseService] ✗✗✗ CRITICAL ERROR: No files in request! ✗✗✗
```
**Solution**: File adding loop had error - check earlier logs for exceptions

### Problem 5: Wrong Field Name
```
[CaseService] File field name: image  ← ❌ WRONG! Should be "images"
```
**Solution**: Field name must be exactly `'images'` (plural, lowercase)

### Problem 6: File Size Issues
```
[CaseService] File size: 0 bytes  ← ❌ PROBLEM!
```
**Solution**: File is empty - check image file integrity

---

## 🧪 Testing Checklist

When you upload images, verify:

- [ ] Screen shows `============ STARTING IMAGE UPLOAD =========`
- [ ] Images exist on disk (`Exists: true`)
- [ ] Images have correct size (> 0 bytes)
- [ ] Case ID is correct
- [ ] Token is retrieved successfully
- [ ] MultipartRequest is created
- [ ] `Total files in request: 2` (or your count)
- [ ] Field name is exactly `images`
- [ ] Content-Type is `image/jpeg`, `image/png`, etc.
- [ ] Authorization header has Bearer token
- [ ] Request is sent successfully
- [ ] Response status is 200 or 201
- [ ] Response contains image URLs

---

## 🐛 How to Debug

1. **Enable logs**
   - Open Flutter console in VS Code
   - Look for `[CaseService]`, `[CaseProvider]`, `[SubmitCaseScreen]` tags

2. **Follow the flow**
   - Search for `BEGIN IMAGE UPLOAD` to find start
   - Search for `FINAL REQUEST DETAILS` to see what's being sent
   - Look for `✗✗✗` for critical errors

3. **Check each step**
   - Are images being added to request?
   - Is the request being sent?
   - What response are you getting?

4. **Copy logs**
   - Save the entire console output
   - Search for `✗` to find errors
   - Look for `CRITICAL ERROR` messages

---

## 📊 Key Metrics to Check

| Check | Expected | Problem If |
|-------|----------|-----------|
| Images to upload | > 0 | 0 or missing |
| File exists | true | false |
| File size | > 0 | 0 bytes |
| Files in request | > 0 | 0 files |
| Field name | images | image / Images |
| Response status | 200/201 | 400/401/404/500 |
| Content-Type | image/* | missing / wrong |
| Authorization | Bearer TOKEN | missing / invalid |

---

## ✅ Success Indicators

You'll know it's working when you see:
1. ✅ `Beginning IMAGE UPLOAD` with correct count
2. ✅ Each image shows `File exists: true`
3. ✅ Each file shows correct MIME type
4. ✅ `Total files in request: [count]` matches your image count
5. ✅ All files have field name `images`
6. ✅ `Sending request...` followed by `Request sent successfully`
7. ✅ Response status is `200` or `201`
8. ✅ Response contains image URLs

---

**Run app now and watch the console logs!**
Check for the `FINAL REQUEST DETAILS` section - that's where you'll see if images are being sent.
