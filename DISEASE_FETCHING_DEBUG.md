# Disease Fetching Troubleshooting Guide

## Improvements Made

1. **Enhanced error handling** - Better response structure parsing
2. **Debug logging** - Console logs to track API calls
3. **Retry mechanism** - User can retry loading diseases if failed
4. **Better error UI** - Shows detailed error messages and error state

## How to Test

### Step 1: Check the API Endpoint

Verify the backend API is running and accessible:

```bash
# Test in browser or Postman
GET http://192.168.1.122:4000/api/disease-labels
Authorization: Bearer YOUR_JWT_TOKEN
```

**Expected Response Format** (one of these):

Option 1: Direct array
```json
[
  {
    "id": "uuid-1",
    "code": "FMD001",
    "name": "Foot and Mouth Disease",
    "animalType": "Cow",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
]
```

Option 2: Wrapped in data
```json
{
  "data": [
    {
      "id": "uuid-1",
      "code": "FMD001",
      "name": "Foot and Mouth Disease",
      "animalType": "Cow",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### Step 2: View Debug Logs

Run the app and open the Submit Case page:

```bash
flutter run
# or
flutter run -v  # for verbose output
```

Look for these logs:
- `Fetching disease labels...` - Request started
- `Disease Labels Response: {...]` - API response
- `Disease labels fetched successfully: X diseases` - Success
- `Error fetching disease labels: ...` - Error details

### Step 3: Check Network in DevTools

1. Open Flutter DevTools:
   ```bash
   flutter pub global run devtools
   ```

2. Open DevTools in browser and connect your app

3. Go to "Network" tab to see HTTP requests

### Step 4: Verify Authentication

Make sure the JWT token is valid:

1. Login to get a token
2. Check TokenService has saved it
3. Verify token isn't expired

You can decode the token at jwt.io to check expiration.

## Common Issues & Solutions

### Issue 1: Empty List Returned

**Symptom**: Screen shows "No diseases available"

**Solution**: Check backend database
```bash
# In Node.js backend terminal
npx prisma studio

# Check if DiseaseLabel table has any records
# If empty, seed the database:
npx prisma db seed
```

### Issue 2: 401 Unauthorized

**Symptom**: Error: "Failed to fetch disease labels (401)"

**Solution**: 
- Verify token is being sent correctly
- Check token isn't expired (valid for 7 days)
- Re-login to get fresh token

### Issue 3: 404 Not Found

**Symptom**: Error: "Failed to fetch disease labels (404)"

**Solution**:
- Verify backend URL in `lib/config/app_config.dart` is correct
- Check route is `/disease-labels` (not `/diseases` or other variant)
- Verify backend is running on port 4000

### Issue 4: Connection Timeout

**Symptom**: "Request timeout. Please try again."

**Solution**:
- Check backend is running and accessible
- Test connectivity: `ping 192.168.1.122`
- For Android emulator use: `http://10.0.2.2:4000/api`
- Update `lib/config/app_config.dart` if needed

## Backend API Endpoint Reference

### Current Implementation

**File**: `src/modules/disease-labels/disease-labels.routes.ts`

Expected implementation:
```typescript
// GET /api/disease-labels
// Returns paginated list of disease labels
// Authentication: Required (Bearer Token)
// Response:
// {
//   "data": [DiseaseLabel[]],
//   "pagination": { page, total, limit }
// }
```

If backend doesn't have this endpoint implemented, see backend.md for implementation details.

## Next Steps if Still Not Working

1. Add print statements in `case_service.dart` to see actual response body
2. Check browser console for CORS errors
3. Test endpoint directly with curl:
   ```bash
   curl -H "Authorization: Bearer TOKEN" \
        http://192.168.1.122:4000/api/disease-labels
   ```
4. Check backend logs for errors

## Code Locations

- **Frontend Service**: `lib/services/case_service.dart`
- **Frontend Provider**: `lib/providers/case_provider.dart`
- **Frontend UI**: `lib/screens/submit_case_screen.dart`
- **Config**: `lib/config/app_config.dart`
- **Backend Endpoint**: `src/modules/disease-labels/disease-labels.routes.ts` (Node.js backend)
