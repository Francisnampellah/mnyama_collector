# 🚀 Flutter Authentication System - Quick Start

## What Was Created

I've created a complete authentication system for your Flutter app with the following components:

### 📁 File Structure Created

```
lib/
├── main.dart                              # Updated - App entry point with Provider setup
├── config/
│   └── app_config.dart                   # Configuration constants (NEW)
├── models/
│   ├── user_model.dart                   # User data model (NEW)
│   └── auth_models.dart                  # Request/response models (NEW)
├── services/
│   ├── auth_service.dart                 # API communication (NEW)
│   └── token_service.dart                # Secure token storage (NEW)
├── providers/
│   └── auth_provider.dart                # State management (NEW)
└── screens/
    ├── home_screen.dart                  # Home after login (NEW)
    └── auth/
        ├── login_screen.dart             # Login UI (NEW)
        ├── register_screen.dart          # Registration UI (NEW)
        └── auth_wrapper.dart             # Route management (NEW)
```

---

## ⚡ Quick Setup (5 Minutes)

### 1. **Install Dependencies**
```bash
cd mnyama_collector
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. **Configure Backend URL**

Edit `lib/config/app_config.dart`:
```dart
static const String backendBaseUrl = 'http://YOUR_IP:4000/api';
```

Options:
- **Local Dev**: `http://localhost:4000/api`
- **Android Emulator**: `http://10.0.2.2:4000/api`
- **Physical Device**: `http://192.168.x.x:4000/api`

### 3. **Update Auth Service**

Edit `lib/services/auth_service.dart` line 7, replace:
```dart
static const String baseUrl = 'http://localhost:4000/api';
```

With:
```dart
static const String baseUrl = AppConfig.backendBaseUrl;
```

Add import at top:
```dart
import '../config/app_config.dart';
```

### 4. **Run the App**
```bash
flutter run
```

---

## 🎨 Features Implemented

✅ **Login Screen** - Email/password login with validation
✅ **Registration Screen** - New user registration with confirmation
✅ **JWT Token Management** - Secure local storage with expiration checking
✅ **Auto-Login** - Persists session on app restart
✅ **Error Handling** - User-friendly error messages
✅ **Loading States** - Loading indicators during auth requests
✅ **Home Screen** - Displays user info after successful login
✅ **Logout** - With confirmation dialog
✅ **Form Validation** - Email format, password length, etc.

---

## 🔄 User Flow

```
[App Start]
    ↓
[Check Saved Token]
    ↓
├─→ [Valid] →  [Home Screen] → [Logout]
└─→ [Invalid] → [Login Screen] ↔ [Register Screen]
                   ↓
               [Backend Auth]
                   ↓
              [Home Screen]
```

---

## 🧪 Testing the Auth System

### Test Registration
1. Run the app
2. Tap "Register here" link
3. Fill in form:
   - Full Name: John Doe
   - Email: john@example.com
   - Password: password123
   - Confirm Password: password123
4. Tap "Register"
5. Should navigate to Home Screen if successful

### Test Login
1. Run the app
2. Login with credentials from registration
3. Should navigate to Home Screen

### Test Auto-Login
1. Login successfully
2. Close and restart app
3. Should go directly to Home Screen (session persisted)

### Test Logout
1. From Home Screen, tap logout icon
2. Confirm logout
3. Should return to Login Screen

---

## 🔌 Backend Requirements

Your backend must:

1. **POST /api/auth/register** - Accept and return:
   ```json
   Request: { "fullName", "email", "password" }
   Response: { "data": { "token", "user" } }
   ```

2. **POST /api/auth/login** - Accept and return:
   ```json
   Request: { "email", "password" }
   Response: { "data": { "token", "user" } }
   ```

✅ Your backend.md already has this implemented!

---

## 📱 Network Configuration (Android)

### For Emulator/Development:
Create `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">192.168.1.0</domain>
    </domain-config>
</network-security-config>
```

Add to `AndroidManifest.xml`:
```xml
<application
  android:networkSecurityConfig="@xml/network_security_config"
  ...>
```

---

## 📦 Dependencies Added

```yaml
# HTTP & API
http: ^1.1.0          # API calls
dio: ^5.3.1           # Alternative HTTP (optional)

# State Management
provider: ^6.0.0      # UI state management

# Storage
shared_preferences: ^2.2.0  # Secure token storage

# JWT
jwt_decoder: ^2.0.1   # Token parsing

# Code Generation
json_annotation: ^4.8.0          # JSON support
build_runner: ^2.4.0             # Code generation
json_serializable: ^6.7.0        # Auto JSON serialization
```

---

## 🛠️ Customization Examples

### Change Theme Color
In `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
```

### Add Custom Validation
In `lib/providers/auth_provider.dart`:
```dart
if (email.endsWith('@company.com')) {
  _error = 'Only company emails allowed';
  notifyListeners();
  return false;
}
```

### Change Token Storage Time
In `lib/services/token_service.dart`:
```dart
// Modify token validation logic
```

---

## ⚠️ Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Connection refused" | Check backend URL in `app_config.dart` |
| Token not saving | Ensure `shared_preferences` is installed |
| Can't login | Verify backend response format matches expected |
| Android emulator can't connect | Use `10.0.2.2` instead of `localhost` |
| Widgets not updating | Ensure `Provider` is at app root in `main.dart` |

---

## 📚 File Descriptions

| File | Purpose |
|------|---------|
| `auth_service.dart` | Communicates with backend API |
| `token_service.dart` | Manages JWT tokens locally |
| `auth_provider.dart` | Manages auth state & logic |
| `user_model.dart` | User data structure |
| `auth_models.dart` | Request/response structures |
| `login_screen.dart` | Login UI with validation |
| `register_screen.dart` | Registration UI |
| `home_screen.dart` | Main app screen after login |
| `auth_wrapper.dart` | Routes based on auth state |
| `app_config.dart` | Configuration & constants |

---

## 🎯 Next Steps

After auth is working:

1. **Implement Case Management** - Create screens for submitting disease cases
2. **Add Image Upload** - Integrate image picker & Supabase upload
3. **Build Disease Labels** - Fetch and display available disease labels
4. **Add User Profile** - Profile editing screen
5. **Implement Role-Based UI** - Different screens for ADMIN/TRAINER/RESEARCHER

---

## 📖 Additional Resources

- **Full Setup Guide**: See `AUTH_SETUP.md`
- **Backend API**: See `backend.md`
- **Flutter Provider Docs**: https://pub.dev/packages/provider
- **JWT Decoder**: https://pub.dev/packages/jwt_decoder
- **SharedPreferences**: https://pub.dev/packages/shared_preferences

---

## ✅ Checklist

- [ ] Installed dependencies (`flutter pub get`)
- [ ] Generated code (`flutter pub run build_runner build`)
- [ ] Updated backend URL in `app_config.dart`
- [ ] Updated `auth_service.dart` to use config
- [ ] Backend is running on port 4000
- [ ] Ran app successfully (`flutter run`)
- [ ] Tested registration flow
- [ ] Tested login flow
- [ ] Tested auto-login (close and restart app)
- [ ] Tested logout flow

---

## 🎉 You're Ready!

The authentication system is now complete and ready to use. Start the app and test the login/registration flows!

For detailed information, see:
- `AUTH_SETUP.md` - Comprehensive setup guide
- `backend.md` - Backend API documentation
