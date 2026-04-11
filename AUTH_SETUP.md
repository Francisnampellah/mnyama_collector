# Flutter Authentication Setup Guide

## 📋 Overview

This guide explains the authentication system implemented for the NeTy Flutter app, which integrates with the backend API described in `backend.md`.

---

## 🎯 What Has Been Implemented

### 1. **Authentication Service** (`lib/services/auth_service.dart`)
   - Communicates with backend API endpoints:
     - `POST /api/auth/register` - Register new user
     - `POST /api/auth/login` - Login user
   - Handles JWT token management
   - Error handling with custom `ApiException`

### 2. **Token Management** (`lib/services/token_service.dart`)
   - Secure local token storage using `SharedPreferences`
   - JWT token validation and expiration checking
   - Stores and retrieves user ID from token claims
   - Clear token on logout

### 3. **Data Models**
   - **User Model** (`lib/models/user_model.dart`)
     - Properties: id, fullName, email, role, createdAt, updatedAt
     - Supports JSON serialization with `json_annotation`
   
   - **Auth Models** (`lib/models/auth_models.dart`)
     - `RegisterRequest` - Registration payload
     - `LoginRequest` - Login payload
     - `AuthResponse` - Backend response with token and user data
     - `ApiException` - Custom error handling

### 4. **State Management** (`lib/providers/auth_provider.dart`)
   - Uses `Provider` package for state management`
   - Handles:
     - User login/registration
     - Logout
     - Auth status persistence on app startup
     - Input validation
     - Error message management
   - Getters: `user`, `token`, `isLoading`, `error`, `isAuthenticated`

### 5. **UI Screens**
   - **Login Screen** (`lib/screens/auth/login_screen.dart`)
     - Email and password inputs
     - Error message display
     - Link to registration
     - Loading indicator during auth
   
   - **Register Screen** (`lib/screens/auth/register_screen.dart`)
     - Full name, email, password, confirm password
     - Input validation
     - Error message display
     - Link to login
     - Loading indicator
   
   - **Home Screen** (`lib/screens/home_screen.dart`)
     - Displays user information after login
     - Quick action cards for future features
     - Logout functionality
   
   - **Auth Wrapper** (`lib/screens/auth/auth_wrapper.dart`)
     - Routes users to login/register or home based on auth state
     - Handles screen transitions

---

## 🛠 Setup Instructions

### Step 1: Install Dependencies

```bash
# Navigate to project directory
cd mnyama_collector

# Get all dependencies
flutter pub get

# Generate JSON serialization files (for user and auth models)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 2: Configure Backend URL

Edit `lib/services/auth_service.dart` and update the base URL:

```dart
static const String baseUrl = 'http://localhost:4000/api';
```

**For Android Emulator**: Use `http://10.0.2.2:4000/api` instead

**For Real Device**: Use your backend's actual IP address (e.g., `http://192.168.x.x:4000/api`)

### Step 3: Update Android Network Security

For HTTP connections in development, update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <uses-permission android:name="android.permission.INTERNET" />
  <!-- ... -->
</manifest>
```

And create/update `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">192.168.1.0</domain>
    </domain-config>
</network-security-config>
```

Reference in `AndroidManifest.xml`:
```xml
<application
  android:networkSecurityConfig="@xml/network_security_config"
  ...>
```

### Step 4: Run the App

```bash
# Start development server
flutter run

# Or with specific device
flutter run -d <device_id>
```

---

## 📱 User Flow

### Registration Flow
1. User taps "Register" link on login screen
2. Fills in Full Name, Email, Password, Confirm Password
3. Validates inputs (empty check, password match, email format, min length)
4. Sends request to `/api/auth/register`
5. Backend returns JWT token and user data
6. App saves token to local storage
7. User is navigated to Home Screen

### Login Flow
1. User enters Email and Password
2. Validates inputs (empty check, email format)
3. Sends request to `/api/auth/login`
4. Backend returns JWT token and user data
5. App saves token to local storage
6. User is navigated to Home Screen

### Logout Flow
1. User taps logout button
2. Confirmation dialog appears
3. Token is cleared from local storage
4. User is navigated back to Login Screen

### Auto-Login on App Startup
1. `AuthProvider` checks if valid token exists in storage
2. If token is valid (not expired), sets `isAuthenticated = true`
3. User is presented with Home Screen
4. If token is expired or missing, user sees Login Screen

---

## 🔐 Security Features

| Feature | Implementation |
|---------|-----------------|
| JWT Token Storage | Secure local storage with `SharedPreferences` |
| Token Expiration | Checked using `jwt_decoder` on app startup |
| Password Security | Hashed on backend with bcryptjs |
| Input Validation | Email format, password length (min 6 chars) |
| API Authorization | Bearer token sent in Authorization header |
| Error Handling | Generic error messages to prevent info leakage |

---

## 📝 API Response Format Reference

The backend must return responses in this format:

### Successful Registration/Login (200-201)
```json
{
  "data": {
    "token": "eyJhbGc...",
    "user": {
      "id": "uuid-here",
      "fullName": "John Doe",
      "email": "john@example.com",
      "role": "TRAINER",
      "createdAt": "2024-04-11T10:00:00Z",
      "updatedAt": "2024-04-11T10:00:00Z"
    }
  }
}
```

### Error Response (400, 401, 500)
```json
{
  "message": "Invalid email or password",
  "code": "AUTH_FAILED",
  "statusCode": 401
}
```

---

## 🔧 Customization

### Change App Title
Edit `lib/main.dart`:
```dart
title: 'Your App Name',
```

### Change Theme Colors
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.yourColor),
```

### Add Custom Validation
Edit `lib/providers/auth_provider.dart` in the `login()` or `register()` methods:
```dart
if (yourValidation) {
  _error = 'Custom error message';
  notifyListeners();
  return false;
}
```

### Change Token Expiration Handling
Edit `lib/services/token_service.dart`:
```dart
// Modify token validation logic in isTokenValid()
```

---

## 🐛 Troubleshooting

### Issue: "Connection refused" Error
**Solution**: 
- Ensure backend is running on port 4000
- Check backend URL in `auth_service.dart`
- For emulator, use `10.0.2.2` instead of `localhost`

### Issue: "Invalid token" on Login
**Solution**:
- Ensure backend is sending token in response
- Check JSON response format matches expected format
- Verify JWT secret is correctly configured on backend

### Issue: Widgets aren't updating after login
**Solution**:
- Ensure `AuthProvider` is provided at app root (check `main.dart`)
- Use `Consumer<AuthProvider>` to listen to changes
- Check `provider` package version compatibility

### Issue: Token not persisting across app sessions
**Solution**:
- Ensure `shared_preferences` dependency is installed
- Check `TokenService.saveToken()` is called after successful login
- Verify app has storage permission on device

---

## 📚 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── user_model.dart               # User data model
│   ├── auth_models.dart              # Auth request/response models
├── services/
│   ├── auth_service.dart             # API communication
│   └── token_service.dart            # Secure token storage
├── providers/
│   └── auth_provider.dart            # State management
└── screens/
    ├── home_screen.dart              # Home after login
    └── auth/
        ├── login_screen.dart         # Login UI
        ├── register_screen.dart      # Registration UI
        └── auth_wrapper.dart         # Route management
```

---

## 🚀 Next Steps

After auth is working, you can:

1. **Implement Case Management**
   - Create `CaseService` for `/api/cases` endpoints
   - Build UI screens for case submission
   - Add image upload functionality

2. **Add Disease Labels**
   - Create service for `/api/disease-labels`
   - Build UI to display available diseases

3. **Implement Image Upload**
   - Create `ImageService` using Supabase Storage
   - Add image picker integration
   - Build image preview/management UI

4. **Add User Profile Management**
   - Create profile editing screen
   - Update user information endpoints

5. **Implement Role-Based UI**
   - Show different screens/options based on user role
   - Restrict features by role (ADMIN, TRAINER, RESEARCHER)

---

## 📖 Dependencies Used

| Package | Version | Purpose |
|---------|---------|---------|
| `http` | ^1.1.0 | HTTP client for API calls |
| `provider` | ^6.0.0 | State management |
| `shared_preferences` | ^2.2.0 | Secure local storage |
| `jwt_decoder` | ^2.0.1 | JWT token parsing |
| `json_annotation` | ^4.8.0 | JSON serialization support |
| `build_runner` | ^2.4.0 | Code generation tool |
| `json_serializable` | ^6.7.0 | JSON code generation |
| `dio` | ^5.3.1 | Alternative HTTP client (optional) |

---

## 💡 Tips

1. **Use `AuthProvider` everywhere** - Access auth state via `Provider.of<AuthProvider>(context)`
2. **Always clear errors** - Call `authProvider.clearError()` before attempting new auth operations
3. **Show loading state** - Use `authProvider.isLoading` to disable buttons during requests
4. **Handle token expiration** - Check token validity before making authenticated API calls
5. **Never hardcode URLs** - Always use configuration for backend URL

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the backend.md for Backend API details
3. Verify network connectivity and CORS settings
4. Check Flutter and package version compatibility

